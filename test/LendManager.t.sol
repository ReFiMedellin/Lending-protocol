// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/LendManager.sol";
import "forge-std/console.sol";
import "./MockERC20.sol";

contract LendManagerTest is Test {
    struct Treshold {
        uint256 minAmount;
        uint8 lenders;
    }

    using stdStorage for StdStorage;

    LendManager lendManager;
    MockERC20 token;
    address currentUser = address(1);

    function setUp() public {
        lendManager = new LendManager(address(this));
        token = new MockERC20();
        lendManager.addToken(address(token));
        LendManager.Treshold[] memory tresholds = new LendManager.Treshold[](1);
        tresholds[0] = LendManager.Treshold(1000, 3);
        lendManager._setTresholds(tresholds);

        token.mint(address(lendManager), 1e18);
        bytes32 slot = keccak256(abi.encode(currentUser, uint256(4)));
        vm.store(address(lendManager), slot, bytes32(uint256(1000)));
        vm.startPrank(currentUser);
    }

    function testRequestAndRepayLend() public {
        console.logUint(2);
        // uint256 amount = 1000;
        // lendManager.requestLend(amount, address(token), block.timestamp + 30 days);
        // uint256 debtAmount = 1000;
        // token.approve(address(lendManager), debtAmount);
        // lendManager.payDebt(debtAmount, address(token), 0);
        // vm.stopPrank();
    }
}
