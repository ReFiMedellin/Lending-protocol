// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@/library/LendManagerUtils.sol";
import "./LiquidityManager.sol";

error UnavailableAmount();

contract LendManager is Ownable, AccessControl, LiquidityManager {
    bytes32 public constant ATTESTATION_RESOLVER = keccak256("ATTESTATION_RESOLVER");

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
        uint256 currentLendedAmount;
        uint256 currentAvailableLendAmount;
    }

    mapping(address => User) private user;

    struct Funds {
        uint256 totalFunds;
        uint256 availableFunds;
        uint256 interests;
    }

    event Funded(address indexed funder, uint256 amount, address indexed token, uint8 decimals);
    event Withdraw(
        address indexed withdrawer, uint256 amount, uint256 interests, address indexed token, uint8 decimals
    );
    event DelayedWithdraw(address indexed withdrawer, uint256 amount, address indexed token, uint8 decimals);
    event Lending(address indexed lender, uint256 amount, address indexed token, uint8 decimals);
    event UserQuotaIncreaseRequest(address indexed caller, address indexed recipent, uint256 amount, address[] signers);
    event UserQuotaIncreased(address indexed caller, address indexed recipent, uint256 amount);
    event UserQuotaSigned(address indexed signer, address indexed recipent, uint256 amount);

    mapping(address => mapping(uint256 => uint256)) private _delayedInterests;
    Funds private funds;

    constructor(address _attestationResolver) Ownable(msg.sender) {
        _grantRole(ATTESTATION_RESOLVER, _attestationResolver);
    }

    function fund(uint256 amount, address token) external {
        require(_tokens[token] == true, "Token is not in whitelist");
        uint8 decimals = ERC20(token).decimals();
        require(decimals > 0, "Error while obtaining decimals");
        require(_tokens[token] == true, "The token is not whitelisted yet");
        require(
            ERC20(token).transferFrom(msg.sender, address(this), amount * 10 ** decimals), "Error while transfer tokens"
        );
        user[msg.sender].currentFund += amount;
        emit Funded(msg.sender, amount, token, decimals);
    }

    function requestWithdraw(uint256 amount, address token) external {
        uint8 decimals = ERC20(token).decimals();
        User storage currentUser = user[msg.sender];
        if (currentUser.currentLendedAmount <= amount && currentUser.currentAvailableLendAmount >= amount) {
            currentUser.currentAvailableLendAmount -= amount;
            funds.availableFunds -= amount;
            _withdraw(amount, token, decimals);
        } else if (currentUser.currentAvailableLendAmount >= amount) {
            currentUser.currentAvailableLendAmount -= amount;
            uint256 interests = Utils.calculateInterest(1, 2, 3);
            _delayedInterests[msg.sender][block.timestamp] = interests;
            emit DelayedWithdraw(msg.sender, amount, token, decimals);
        } else {
            revert UnavailableAmount();
        }
    }

    function claimDelayedWithdraw(uint256 amount, address token, uint256 timestamp) external {
        uint8 decimals = ERC20(token).decimals();
        User storage currentUser = user[msg.sender];
        uint256 interests = _delayedInterests[msg.sender][timestamp];
        require(decimals > 0, "Error while obtaining decimals");
        require(amount > 0, "The amount must be greather than 0");
        require(_tokens[token] == true, "The token is not whitelisted yet");
        require(
            currentUser.currentLendedAmount <= amount && currentUser.currentAvailableLendAmount >= amount,
            "Invalid to claim delayed withdraw"
        );
        _withdraw(amount + interests, token, decimals);
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

    function requestIncreaseQuota(address recipent, uint256 amount, address[] calldata signers) external {
        require(signers.length >= 3, "Signers must be at leat 3");
        require(signers.length <= 10, "Signers must be least than 10");
        require(amount > 0, "Amount must be greather than 0");
        user[recipent].userQuotaRequests.push(UserQuotaRequest(amount, 0, new address[](0), signers));
        emit UserQuotaIncreaseRequest(msg.sender, recipent, amount, signers);
    }

    function _increaseQuota(address recipent, uint8 index, address caller) external {
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
        emit UserQuotaSigned(caller, recipent, userQuotaRequest.amount);
    }

    function _withdraw(uint256 amount, address token, uint8 decimals) private {
        User storage currentUser = user[msg.sender];
        require(decimals > 0, "Error while obtaining decimals");
        require(amount > 0, "The amount must be greather than 0");
        require(_tokens[token] == true, "The token is not whitelisted yet");
        require((currentUser.currentFund -= amount) >= 0, "Invalid amount");
        uint256 percentaje = (currentUser.currentFund * funds.totalFunds) / 100;
        uint256 interests = funds.interests * percentaje;
        funds.interests -= interests;
        currentUser.currentFund -= amount;
        funds.totalFunds -= amount + interests;

        require(
            ERC20(token).transfer(msg.sender, (amount * (10 ** decimals)) + interests), "Failed when withdrawing funds"
        );
        emit Withdraw(msg.sender, amount, interests, token, decimals);
    }
}
