// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ReFiMedLend.sol";
import "../src/Resolver.sol";
import "./MockERC20.sol";
import {SchemaRegistry} from "../lib/eas-contracts/contracts/SchemaRegistry.sol";
import {EAS} from "../lib/eas-contracts/contracts/EAS.sol";

contract ReFiMedLend is Test {
    struct Treshold {
        uint256 minAmount;
        uint8 lenders;
    }

    using stdStorage for StdStorage;

    Resolver public resolver;
    ReFiMedLend public ReFiMedLend;

    MockERC20 public token;
    address public currentUser = address(1);

    function setUp() public {
        ReFiMedLend = new ReFiMedLend(address(this));
        schemaRegistry = new SchemaRegistry();
        eas = new EAS(address(schemaRegistry));
        resolver = new Resolver(eas);
        token = new MockERC20();
        ReFiMedLend.addToken(address(resolver));
        ReFiMedLend._setTresholds(tresholds);
        token.mint(address(lendManager), 1e18);
    }

    function testRequestAndRepayLend() public view {
        // uint256 amount = 1000;
        // lendManager.requestLend(amount, address(token), block.timestamp + 30 days);
        // uint256 debtAmount = 1000;
        // token.approve(address(lendManager), debtAmount);
        // lendManager.payDebt(debtAmount, address(token), 0);
        // vm.stopPrank();
    }
}
