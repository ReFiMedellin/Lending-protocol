// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {ReFiMedLendUpgradeable} from "src/ReFiMedLendUpgradeable.sol";

contract DeployImplementation is Script {
    function run() external {
        vm.startBroadcast();
        ReFiMedLendUpgradeable lendManager = new ReFiMedLendUpgradeable();
        console.log("LendManager address: ", address(lendManager));
        vm.stopBroadcast();
    }
}
