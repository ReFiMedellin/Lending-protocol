// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {ReFiMedLendResolver} from "../src/ReFiMedLendResolver.sol";
import {ReFiMedLend} from "../src/ReFiMedLend.sol";
import {IEAS} from "@ethereum-attestation-service/contracts/IEAS.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        ReFiMedLendResolver lendResolver = new ReFiMedLendResolver(IEAS(0x4200000000000000000000000000000000000021));
        console.log("LendResolver address: ", address(lendResolver));

        // ReFiMedLend lendManager = new ReFiMedLend(address(lendResolver));
        // console.log("LendManager address: ", address(lendManager));

        // lendResolver.setLendManager(address(lendManager));

        vm.stopBroadcast();
    }
}
