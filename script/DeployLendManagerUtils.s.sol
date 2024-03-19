// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/LendManager.sol";

contract DeployMyContract is Script {
    function run() external {
        vm.startBroadcast();

        // Desplega tu contrato aquí
        LendManager lendManager = new LendManager(address(0));

        vm.stopBroadcast();
    }
}
