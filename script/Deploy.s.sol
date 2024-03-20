// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {LendResolver} from "../src/Resolver.sol";
import {LendManager} from "../src/LendManager.sol";
import {IEAS} from "@ethereum-attestation-service/contracts/IEAS.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        LendResolver lendResolver = new LendResolver(IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e));
        console.log("LendResolver address: ", address(lendResolver));

        // Desplegar ContratoB con la dirección de ContratoA
        LendManager lendManager = new LendManager(address(lendResolver));
        console.log("LendManager address: ", address(lendManager));

        // Ejecutar una función de ContratoA a través de ContratoB
        lendResolver.setLendManager(address(lendManager));

        vm.stopBroadcast();
    }
}
