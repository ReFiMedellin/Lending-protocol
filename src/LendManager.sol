// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@/library/LendManagerUtils.sol";

error UnavailableAmount();

contract LendManager is Ownable, AccessControl {
    event Funded(address indexed funder, uint256 amount, address indexed token, uint8 decimals);

    event Withdraw(
        address indexed withdrawer, uint256 amount, uint256 interests, address indexed token, uint8 decimals
    );

    event Debt(address indexed debtor, uint256 amount, uint256 interests, address indexed token, uint8 decimals);

    event lendRepaid(address indexed lender, uint256 amount, address indexed token, uint8 decimals);

    event Lending(address indexed lender, uint256 amount, address indexed token, uint8 decimals);

    event UserQuotaIncreaseRequest(address indexed caller, address indexed recipent, uint256 amount, address[] signers);

    event UserQuotaIncreased(address indexed caller, address indexed recipent, uint256 amount);

    event UserQuotaSigned(address indexed signer, address indexed recipent, uint256 amount);

    event TokenAdded(address indexed tokenAddress);

    bytes32 private immutable ATTESTATION_RESOLVER = keccak256("ATTESTATION_RESOLVER");
    uint256 INTEREST_RATE_PER_DAY = 16308;
    uint120 public interestAccrualRate = 10;
    Treshold[] private tresholds;
    mapping(address => User) public user;

    struct Treshold {
        uint256 minAmount;
        uint8 lenders;
    }

    struct Lend {
        uint256 initialAmount;
        uint256 currentAmount;
        address token;
        uint256 expectPaymentDue;
        uint256 latestDebtTimestamp;
    }

    struct UserQuotaRequest {
        uint256 amount;
        uint8 successfulSigns;
        address[] signers;
        address[] signedBy;
        address caller;
    }

    struct User {
        uint256 quota;
        uint256 availableDelegateQuota;
        Lend[] currentLends;
        UserQuotaRequest[] userQuotaRequests;
        uint256 currentFund;
        uint256 interestShares;
        uint256 lastFund;
        Lender[] lenders;
    }

    struct Lender {
        address lender;
        uint256 amount;
    }

    struct Funds {
        uint256 totalFunds;
        uint256 interests;
        uint256 totalInterestShares;
        uint256 interestPerShare;
    }

    mapping(address => bool) internal _tokens;

    mapping(address => mapping(uint256 => uint256)) private _delayedInterests;
    Funds private funds;

    constructor(address _attestationResolver) Ownable(msg.sender) {
        _grantRole(ATTESTATION_RESOLVER, _attestationResolver);
    }

    function fund(uint256 amount, address token) external {
        require(_tokens[token] == true, "Token is not in whitelist");
        uint8 decimals = ERC20(token).decimals();
        require(decimals > 0, "Error while obtaining decimals");
        require(
            ERC20(token).transferFrom(msg.sender, address(this), amount * 10 ** decimals), "Error while transfer tokens"
        );
        if (funds.totalFunds == 0) {
            user[msg.sender].interestShares = amount;
            funds.totalInterestShares = amount;
        } else {
            uint256 userShares = (amount * funds.totalInterestShares) / funds.totalFunds;
            user[msg.sender].interestShares += userShares;
            funds.totalInterestShares += userShares;
        }
        user[msg.sender].currentFund += amount;
        user[msg.sender].lastFund = block.timestamp;
        user[msg.sender].availableDelegateQuota += amount * 4 / 5;
        emit Funded(msg.sender, amount, token, decimals);
    }

    function withdraw(uint256 amount, address token) external {
        uint8 decimals = ERC20(token).decimals();
        User storage currentUser = user[msg.sender];
        uint256 lastFund = currentUser.lastFund;
        uint256 daysSinceLastFund = LendManagerUtils.timestampsToDays(lastFund, block.timestamp);
        require(daysSinceLastFund >= 180, "The user must wait at least 180 days to withdraw funds");
        require(currentUser.currentFund >= amount, "Insuficent funds");
        uint256 owedInterest = (currentUser.interestShares * funds.interestPerShare) / 1e18;
        funds.interests -= owedInterest;
        _withdraw(amount + owedInterest, token, decimals);
    }

    function requestLend(uint256 amount, address token, uint256 paymentDue) external {
        User storage currentUser = user[msg.sender];
        require(currentUser.quota >= amount, "The user has less quota than the required amount");
        uint8 decimals = ERC20(token).decimals();
        require(decimals > 0, "Error while obtaining decimals");
        uint256 balance = ERC20(token).balanceOf(address(this));
        require(balance >= amount * 10 ** decimals, "Insuficent liquidity");
        currentUser.currentLends.push(Lend(amount, amount, token, paymentDue, 0));
        currentUser.quota -= amount;
        require(ERC20(token).transfer(msg.sender, amount * 10 ** decimals), "Error while transfering assets");
        emit Lending(msg.sender, amount, token, decimals);
    }

    function payDebt(uint256 amount, address token, uint256 lendIndex) external {
        User storage currentUser = user[msg.sender];
        Lend storage currentLend = currentUser.currentLends[lendIndex];
        require(currentLend.currentAmount >= amount, "Invalid amount to pay");
        uint256 time = LendManagerUtils.timestampsToDays(currentLend.latestDebtTimestamp, block.timestamp);
        (uint256 interests, uint256 totalDebt) =
            LendManagerUtils.calculateInterest(time, INTEREST_RATE_PER_DAY, currentLend.currentAmount);
        uint8 decimals = ERC20(token).decimals();
        require(decimals > 0, "Error while obtaining decimals");
        require(_tokens[token], "The token is not whitelisted yet");
        require(
            ERC20(token).transferFrom(msg.sender, address(this), (amount + interests) * 10 ** decimals),
            "Error while transfering assets"
        );
        currentLend.currentAmount -= amount + interests;
        if (funds.totalInterestShares > 0) {
            funds.interestPerShare += (interests * 1e18) / funds.totalInterestShares;
        }
        if (currentLend.currentAmount == 0) {
            currentUser.currentLends[lendIndex] = currentUser.currentLends[currentUser.currentLends.length - 1];
            currentUser.currentLends.pop();
            currentUser.quota += currentLend.initialAmount;
            emit lendRepaid(msg.sender, amount, token, decimals);
        }
        emit Debt(msg.sender, amount, interests, token, decimals);
    }

    function requestIncreaseQuota(address recipent, uint256 amount, address[] calldata signers) external {
        require(signers.length >= 3, "Signers must be at leat 3");
        require(signers.length <= 10, "Signers must be least than 10");
        require(amount > 0, "Amount must be greather than 0");
        require(user[msg.sender].currentFund >= amount, "Insuficent funds");
        require(user[msg.sender].availableDelegateQuota >= amount, "Unavailable amount");
        uint8 maxLenders = 0;
        for (uint8 i = 0; i < tresholds.length; i++) {
            if (user[msg.sender].currentFund < tresholds[i].minAmount) {
                if (i == 0) {
                    maxLenders = 0;
                } else {
                    maxLenders = tresholds[i - 1].lenders;
                }
            }
        }

        require(user[msg.sender].lenders.length <= maxLenders, "The user has reached the maximum number of lenders");
        user[recipent].userQuotaRequests.push(UserQuotaRequest(amount, 0, new address[](0), signers, msg.sender));
        emit UserQuotaIncreaseRequest(msg.sender, recipent, amount, signers);
    }

    function addToken(address tokenAddress) external onlyOwner {
        _tokens[tokenAddress] = true;
        emit TokenAdded(tokenAddress);
    }

    function getUserLendsPaginated(address userAddress, uint256 page, uint256 pageSize)
        external
        view
        returns (Lend[] memory)
    {
        User storage currentUser = user[userAddress];
        uint256 totalLends = currentUser.currentLends.length;
        uint256 totalPages = totalLends / pageSize;
        if (totalLends % pageSize > 0) {
            totalPages += 1;
        }
        require(page <= totalPages, "Invalid page");
        require(pageSize > 0 && pageSize <= totalPages, "Invalid page size");
        uint256 startIndex = (page - 1) * pageSize;
        uint256 endIndex = startIndex + pageSize;
        if (endIndex > totalLends) {
            endIndex = totalLends;
        }
        Lend[] memory result = new Lend[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = currentUser.currentLends[i];
        }
        return result;
    }

    function decreaseQuota(address recipent, uint256 amount) external {
        require(user[recipent].quota >= amount, "Insuficent quota");
        bool isBenefactor = false;
        uint8 index = 0;
        for (uint8 i = 0; i < user[msg.sender].lenders.length; i++) {
            if (user[msg.sender].lenders[i].lender == recipent) {
                isBenefactor = true;
                index = i;
                break;
            }
        }
        require(isBenefactor, "The caller is not a benefactor");
        user[recipent].quota -= amount;
        user[msg.sender].availableDelegateQuota += amount;
        if (user[recipent].quota == 0) {
            user[msg.sender].lenders[index] = user[msg.sender].lenders[user[msg.sender].lenders.length - 1];
            user[msg.sender].lenders.pop();
        }
    }

    function _increaseQuota(address recipent, uint16 index, address caller) external returns (bool) {
        require(hasRole(ATTESTATION_RESOLVER, msg.sender), "Caller is not a valid attestation resolver");

        bool senderIsSigner = false;
        UserQuotaRequest storage userQuotaRequest = user[recipent].userQuotaRequests[index];
        for (uint8 signerIndex; signerIndex <= userQuotaRequest.signers.length; signerIndex++) {
            if (userQuotaRequest.signers[signerIndex] == caller) {
                senderIsSigner = true;
            }
        }
        bool senderHasSigned = false;
        for (uint8 signerIndex; signerIndex <= userQuotaRequest.signers.length; signerIndex++) {
            if (userQuotaRequest.signedBy[signerIndex] == caller) {
                senderIsSigner = true;
            }
        }
        require(senderIsSigner, "Sender is not a valid signer");
        require(!senderHasSigned, "Sender has signed yet");
        userQuotaRequest.signedBy.push(caller);
        userQuotaRequest.successfulSigns += 1;
        if (userQuotaRequest.successfulSigns >= 3) {
            user[recipent].quota += userQuotaRequest.amount;
            emit UserQuotaIncreased(caller, recipent, userQuotaRequest.amount);
        }

        for (uint8 i = 0; i < user[userQuotaRequest.caller].lenders.length; i++) {
            if (user[userQuotaRequest.caller].lenders[i].lender == recipent) {
                user[userQuotaRequest.caller].lenders[i].amount += userQuotaRequest.amount;
                user[userQuotaRequest.caller].availableDelegateQuota -= userQuotaRequest.amount;
                emit UserQuotaSigned(caller, recipent, userQuotaRequest.amount);
                return true;
            }
        }
        user[userQuotaRequest.caller].lenders.push(Lender(recipent, userQuotaRequest.amount));
        return true;
    }

    function _setTresholds(Treshold[] calldata newTresholds) public onlyOwner {
        delete tresholds;
        for (uint256 i = 0; i < newTresholds.length; i++) {
            tresholds.push(newTresholds[i]);
        }
    }

    function _withdraw(uint256 amount, address token, uint8 decimals) private {
        User storage currentUser = user[msg.sender];
        require(ERC20(token).balanceOf(address(this)) >= amount * (10 ** decimals), "Insuficent liquidity");
        require(decimals > 0, "Error while obtaining decimals");
        require(amount > 0, "The amount must be greather than 0");
        require(_tokens[token] == true, "The token is not whitelisted yet");
        require((currentUser.currentFund -= amount) >= 0, "Invalid amount");
        uint256 percentaje = (currentUser.currentFund * funds.totalFunds) / 100;
        uint256 interests = funds.interests * percentaje;
        funds.interests -= interests;
        currentUser.currentFund -= amount;
        funds.totalFunds -= amount;

        require(
            ERC20(token).transfer(msg.sender, (amount * (10 ** decimals)) + interests), "Failed when withdrawing funds"
        );
        emit Withdraw(msg.sender, amount, interests, token, decimals);
    }
}
