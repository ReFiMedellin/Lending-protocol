// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ILendManager {
    // Eventos
    event Funded(address indexed funder, uint256 amount, address indexed token, uint8 decimals);
    event Withdraw(
        address indexed withdrawer, uint256 amount, uint256 interests, address indexed token, uint8 decimals
    );
    event DelayedWithdraw(address indexed withdrawer, uint256 amount, address indexed token, uint8 decimals);
    event Lending(address indexed lender, uint256 amount, address indexed token, uint8 decimals);
    event UserQuotaIncreaseRequest(
        address indexed caller, address indexed recipient, uint256 amount, address[] signers
    );
    event UserQuotaIncreased(address indexed caller, address indexed recipient, uint256 amount);
    event UserQuotaSigned(address indexed signer, address indexed recipient, uint256 amount);

    // Error
    error UnavailableAmount();

    // Funciones
    function fund(uint256 amount, address token) external;
    function requestWithdraw(uint256 amount, address token) external;
    function claimDelayedWithdraw(uint256 amount, address token, uint256 timestamp) external;
    function requestLend(uint256 amount, address token, uint256 paymentDue) external;
    function requestIncreaseQuota(address recipient, uint256 amount, address[] calldata signers) external;
    function _increaseQuota(address recipient, uint16 index, address caller) external returns (bool);
}
