// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract LendManager {

    struct Lend {
        uint256 initialAmount;
        uint256 currentAmount;
        address token;
        uint256 expectPaymentDue;
    };

    struct requestUserQuota {
        uint256 amount;
        address[] signers;
        mapping(address => bool) hasSigned;
    }

    struct User {
        mapping(address => Token)  quotas;
        Lend[] currentLends;
        uint256 currentFund;
        uint256 currentLendedAmount;
    };

    struct Token{
        uint256 quota;
        address tokenAddress;
    }

    uint256 private totalFunds;

    
    mapping(address =>User) private user



  constructor(){
  }

  





}