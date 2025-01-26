// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {ReFiMedLendResolver} from "../src/ReFiMedLendResolver.sol";
import {ReFiMedLend} from "../src/ReFiMedLend.sol";
import {ReFiMedLendUpgradeable} from "../src/ReFiMedLendUpgradeable.sol";
import {IEAS} from "@ethereum-attestation-service/contracts/IEAS.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployLend is Script {
    address constant SEPOLIA_EAS = 0xC2679fBD37d54388Ce493F1DB75320D236e1815e;

    uint256 constant SEPOLIA_CHAIN_ID = 11155111;

    function run() external {
        vm.startBroadcast();

        ReFiMedLendResolver lendResolver = new ReFiMedLendResolver(IEAS(SEPOLIA_EAS));

        console.log("LendResolver address: ", address(lendResolver));

        ReFiMedLend lendManager = new ReFiMedLend(address(lendResolver));
        console.log("LendManager address: ", address(lendManager));

        lendResolver.setLendManager(address(lendManager));

        vm.stopBroadcast();
    }
}

contract DeployLendUpgradeable is Script {
    address constant SEPOLIA_EAS = 0xC2679fBD37d54388Ce493F1DB75320D236e1815e;

    function run() external returns (address) {
        address proxy = deployLend();
        return proxy;
    }

    function deployLend() public returns (address) {
        vm.startBroadcast();

        ReFiMedLendResolver lendResolver = new ReFiMedLendResolver(IEAS(SEPOLIA_EAS));
        console.log("LendResolver address: ", address(lendResolver));

        ReFiMedLendUpgradeable lendManager = new ReFiMedLendUpgradeable(); // Implementation
        console.log("LendManager address: ", address(lendManager));

        ERC1967Proxy proxy = new ERC1967Proxy(
          address(lendManager),
          abi.encodeCall(lendManager.initialize, (address(lendResolver), msg.sender, msg.sender))
        );

        console.log("Proxy address: ", address(proxy));

        lendResolver.setLendManager(address(lendManager));

        vm.stopBroadcast();
        return address(proxy);
    }
}
