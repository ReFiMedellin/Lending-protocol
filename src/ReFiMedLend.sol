// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@/library/LendManagerUtils.sol";

contract ReFiMedLend is Ownable, AccessControl, Pausable {
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
    }

    struct User {
        uint256 quota;
        Lend[] currentLends;
        UserQuotaRequest[] userQuotaRequests;
        uint256 currentFund;
        uint256 interestShares;
        uint256 lastFund;
    }

    struct Funds {
        uint256 totalFunds;
        uint256 interests;
        uint256 totalInterestShares;
        uint256 interestPerShare;
    }

    bytes32 private constant ATTESTATION_RESOLVER = keccak256("ATTESTATION_RESOLVER");
    uint256 public INTEREST_RATE_PER_DAY = 16308;
    uint256 private constant _SCALAR = 1e3;

    mapping(address => User) public user;
    mapping(address => mapping(address => uint256)) private _userTokenBalances;

    mapping(address => bool) internal _tokens;

    Funds public funds;

    event Funded(address indexed funder, uint256 amount, address indexed token, uint8 decimals);

    event Withdraw(
        address indexed withdrawer, uint256 amount, uint256 interests, address indexed token, uint8 decimals
    );

    event Debt(address indexed debtor, uint256 amount, uint256 interests, address indexed token, uint8 decimals);

    event LendRepaid(address indexed lender, uint256 amount, address indexed token, uint8 decimals);

    event Lending(address indexed lender, uint256 amount, address indexed token, uint8 decimals);

    event UserQuotaIncreaseRequest(
        address indexed caller, uint16 indexed index, address indexed recipent, uint256 amount, address[] signers
    );

    event UserQuotaChanged(address indexed caller, address indexed recipent, uint256 amount);

    event UserQuotaSigned(address indexed signer, uint16 indexed index, address indexed recipent, uint256 amount);

    event TokenAdded(address indexed tokenAddress, string symbol, string name);

    error UnavailableAmount();

    constructor(address _attestationResolver) Ownable(msg.sender) {
        _grantRole(ATTESTATION_RESOLVER, _attestationResolver);
    }

    function fund(uint256 amount, address token) external whenNotPaused {
        require(_tokens[token], "Token is not in whitelist");
        uint8 decimals = ERC20(token).decimals();
        require(decimals > 0, "Error while obtaining decimals");

        uint256 scaledAmount = amount * _SCALAR;
        if (funds.totalFunds == 0) {
            user[msg.sender].interestShares = scaledAmount;
            funds.totalInterestShares = scaledAmount;
            funds.totalFunds = scaledAmount;
        } else {
            uint256 userShares = funds.totalInterestShares / funds.totalFunds;
            user[msg.sender].interestShares += userShares;
            funds.totalInterestShares += userShares;
            funds.totalFunds += scaledAmount;
        }
        user[msg.sender].currentFund += scaledAmount;
        user[msg.sender].lastFund = block.timestamp;
        _userTokenBalances[msg.sender][token] += scaledAmount;
        require(
            ERC20(token).transferFrom(msg.sender, address(this), amount * 10 ** decimals), "Error while transfer tokens"
        );
        emit Funded(msg.sender, amount, token, decimals);
    }

    function withdraw(uint256 amount, address token) external {
        uint8 decimals = ERC20(token).decimals();
        uint256 scaledAmount = amount * _SCALAR;
        User storage currentUser = user[msg.sender];
        uint256 lastFund = currentUser.lastFund;
        uint256 daysSinceLastFund = Utils.timestampsToDays(lastFund, block.timestamp);
        require(daysSinceLastFund >= 180, "The user must wait at least 180 days to withdraw funds");
        require(currentUser.currentFund >= scaledAmount, "Insuficent funds");
        require(_userTokenBalances[msg.sender][token] >= scaledAmount, "Insufficient token balance");
        _userTokenBalances[msg.sender][token] -= scaledAmount;
        uint256 owedInterest = (currentUser.interestShares * funds.interestPerShare) / 1e18;
        funds.totalInterestShares -= currentUser.interestShares;
        currentUser.interestShares -= currentUser.interestShares;
        funds.interests -= owedInterest;
        if (funds.totalInterestShares > 0) {
            funds.interestPerShare = (funds.interests * 1e18) / funds.totalInterestShares;
        }
        _withdraw(amount, owedInterest, token, decimals);
    }

    function withdrawWithoutInterests(uint256 amount, address token) external {
        uint8 decimals = ERC20(token).decimals();
        uint256 scaledAmount = amount * _SCALAR;
        User storage currentUser = user[msg.sender];
        uint256 lastFund = currentUser.lastFund;
        uint256 daysSinceLastFund = Utils.timestampsToDays(lastFund, block.timestamp);
        require(daysSinceLastFund >= 180, "The user must wait at least 180 days to withdraw funds");
        require(currentUser.currentFund >= scaledAmount, "Insuficent funds");
        require(_userTokenBalances[msg.sender][token] >= scaledAmount, "Insufficient token balance");
        _userTokenBalances[msg.sender][token] -= scaledAmount;
        _withdraw(amount, 0, token, decimals);
    }

    function requestLend(uint256 amount, address token, uint256 paymentDue) external whenNotPaused {
        User storage currentUser = user[msg.sender];
        uint256 scaledAmount = amount * _SCALAR;
        require(currentUser.quota >= scaledAmount, "The user has less quota than the required amount");
        uint8 decimals = ERC20(token).decimals();
        require(decimals > 0, "Error while obtaining decimals");
        uint256 balance = ERC20(token).balanceOf(address(this));
        require(balance >= amount * 10 ** decimals, "Insuficent liquidity");
        currentUser.currentLends.push(Lend(scaledAmount, scaledAmount, token, paymentDue, 0));
        currentUser.quota -= scaledAmount;
        require(ERC20(token).transfer(msg.sender, amount * 10 ** decimals), "Error while transfering assets");
        emit Lending(msg.sender, amount, token, decimals);
    }

    function payDebt(uint256 amount, address token, uint256 lendIndex) external {
        User storage currentUser = user[msg.sender];
        Lend storage currentLend = currentUser.currentLends[lendIndex];
        uint256 scaledAmount = amount;
        uint256 time = Utils.timestampsToDays(currentLend.latestDebtTimestamp, block.timestamp);
        (uint256 interests, uint256 totalDebt) =
            Utils.calculateInterest(time, INTEREST_RATE_PER_DAY, currentLend.currentAmount);
        uint8 decimals = ERC20(token).decimals();
        currentLend.currentAmount += interests;
        require(currentLend.currentAmount >= scaledAmount, "Invalid amount to pay");
        require(decimals > 0, "Error while obtaining decimals");
        require(_tokens[token], "The token is not whitelisted yet");

        currentLend.currentAmount -= scaledAmount;
        funds.interests += interests;
        if (funds.totalInterestShares > 0) {
            funds.interestPerShare += (interests * 1e18) / funds.totalInterestShares;
        }
        if (currentLend.currentAmount == 0) {
            currentUser.currentLends[lendIndex] = currentUser.currentLends[currentUser.currentLends.length - 1];
            currentUser.currentLends.pop();
            currentUser.quota += currentLend.initialAmount;
            emit LendRepaid(msg.sender, amount, token, decimals);
        }
        require(
            ERC20(token).transferFrom(msg.sender, address(this), scaledAmount * 10 ** (decimals - 3)),
            "Error while transfering assets"
        );
        emit Debt(msg.sender, amount, interests, token, decimals);
    }

    function requestIncreaseQuota(address recipent, uint256 amount, address[] calldata signers)
        external
        whenNotPaused
        onlyOwner
    {
        uint256 scaledAmount = amount * _SCALAR;
        address[] memory seenSigners = new address[](signers.length);

        require(signers.length >= 3, "Signers must be at leat 3");
        require(signers.length <= 10, "Signers must be least than 10");
        require(amount > 0, "Amount must be greather than 0");
        user[recipent].userQuotaRequests.push(UserQuotaRequest(scaledAmount, 0, new address[](0), new address[](0)));
        uint256 seenCount = 0;
        for (uint8 i; i < signers.length; ++i) {
            address signer = signers[i];
            for (uint8 j = 0; j < seenCount; ++j) {
                require(signer != seenSigners[j], "Duplicate signer detected");
            }
            seenSigners[seenCount] = signer;
            seenCount++;
            user[recipent].userQuotaRequests[user[recipent].userQuotaRequests.length - 1].signers.push(signer);
        }
        emit UserQuotaIncreaseRequest(
            msg.sender, uint16(user[recipent].userQuotaRequests.length - 1), recipent, amount, signers
        );
    }

    function addToken(address tokenAddress) external onlyOwner whenNotPaused {
        _tokens[tokenAddress] = true;
        string memory symbol = ERC20(tokenAddress).symbol();
        string memory name = ERC20(tokenAddress).name();
        emit TokenAdded(tokenAddress, symbol, name);
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
        for (uint256 i = startIndex; i < endIndex; ++i) {
            result[i - startIndex] = currentUser.currentLends[i];
        }
        return result;
    }

    function getUserQuotaRequests(address userAddress, uint256 page, uint256 pageSize)
        external
        view
        returns (UserQuotaRequest[] memory)
    {
        UserQuotaRequest[] storage userQuotaRequests = user[userAddress].userQuotaRequests;
        uint256 totalLends = userQuotaRequests.length;
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
        UserQuotaRequest[] memory result = new UserQuotaRequest[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; ++i) {
            result[i - startIndex] = userQuotaRequests[i];
        }
        return result;
    }

    function decreaseQuota(address recipent, uint256 amount) external whenNotPaused onlyOwner {
        uint256 scaledAmount = amount * _SCALAR;
        require(user[recipent].quota >= scaledAmount, "Insuficent quota");
        user[recipent].quota -= scaledAmount;
        emit UserQuotaChanged(msg.sender, recipent, user[recipent].quota);
    }

    function increaseQuota(address recipent, uint16 index, address caller, uint256 amount) external returns (bool) {
        require(hasRole(ATTESTATION_RESOLVER, msg.sender), "Caller is not a valid attestation resolver");

        bool senderIsSigner;
        UserQuotaRequest storage userQuotaRequest = user[recipent].userQuotaRequests[index];
        require(amount == userQuotaRequest.amount, "The attestation amount does not match the request");
        uint256 scaledAmount = userQuotaRequest.amount * _SCALAR;
        uint256 userQuotaSignersLength = userQuotaRequest.signers.length;
        for (uint8 signerIndex; signerIndex < userQuotaSignersLength; ++signerIndex) {
            if (userQuotaRequest.signers[signerIndex] == caller) {
                senderIsSigner = true;
            }
        }
        bool senderHasSigned;
        uint256 userQuotaSignedByLength = userQuotaRequest.signedBy.length;
        for (uint8 signerIndex; signerIndex < userQuotaSignedByLength; ++signerIndex) {
            if (userQuotaRequest.signedBy.length == 0) {
                break;
            }
            if (userQuotaRequest.signedBy[signerIndex] == caller) {
                senderIsSigner = true;
            }
        }
        require(senderIsSigner, "Sender is not a valid signer");
        require(!senderHasSigned, "Sender has signed yet");
        userQuotaRequest.signedBy.push(caller);
        userQuotaRequest.successfulSigns += 1;
        if (userQuotaRequest.successfulSigns == 3) {
            user[recipent].quota += scaledAmount;
            emit UserQuotaChanged(caller, recipent, user[recipent].quota);
        }
        emit UserQuotaSigned(caller, index, recipent, userQuotaRequest.amount);
        return true;
    }

    function getSpareFunds(address token) external onlyOwner {
        uint256 balance = ERC20(token).balanceOf(address(this));
        require(funds.totalFunds == 0, "The total funds must be 0");
        require(balance > 0, "The balance must be greather than 0");
        require(ERC20(token).transfer(msg.sender, balance), "Error while transfering funds");
    }

    function setInterestPerDay(uint256 interestRate) external onlyOwner {
        INTEREST_RATE_PER_DAY = interestRate;
    }

    function _withdraw(uint256 amount, uint256 interests, address token, uint8 decimals) private {
        uint256 scaledAmount = amount * _SCALAR;
        User storage currentUser = user[msg.sender];
        require(ERC20(token).balanceOf(address(this)) >= amount * (10 ** decimals), "Insuficent liquidity");
        require(decimals > 0, "Error while obtaining decimals");
        require(amount > 0, "The amount must be greather than 0");
        require(_tokens[token], "The token is not whitelisted yet");
        require(currentUser.currentFund >= scaledAmount, "Invalid amount");
        currentUser.currentFund -= scaledAmount;
        funds.totalFunds -= scaledAmount;

        require(
            ERC20(token).transfer(msg.sender, ((scaledAmount + interests) * 10 ** (decimals - 3))),
            "Failed when withdrawing funds"
        );
        emit Withdraw(msg.sender, amount, interests, token, decimals);
    }
}
