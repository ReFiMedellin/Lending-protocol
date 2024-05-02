// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {Defender, ApprovalProcessResponse} from "openzeppelin-foundry-upgrades/Defender.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {ReFiMedLendUpgradeable} from "src/ReFiMedLendUpgradeable.sol";
import {IEAS} from "@ethereum-attestation-service/contracts/IEAS.sol";
import {ReFiMedLendResolver} from "../src/ReFiMedLendResolver.sol";

contract DefenderDeploy is Script {
    function setUp() public {}

    function run() public {
        ApprovalProcessResponse memory upgradeApprovalProcess = Defender.getUpgradeApprovalProcess();

        if (upgradeApprovalProcess.via == address(0)) {
            revert(
                string.concat(
                    "Upgrade approval process with id ",
                    upgradeApprovalProcess.approvalProcessId,
                    " has no assigned address"
                )
            );
        }

        Options memory opts;
        opts.defender.useDefenderDeploy = true;
        ReFiMedLendResolver lendResolver = new ReFiMedLendResolver(IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e));
        address proxy = Upgrades.deployUUPSProxy(
            "ReFiMedLendUpgradeable.sol",
            abi.encodeCall(ReFiMedLendUpgradeable.initialize, (address(lendResolver), upgradeApprovalProcess.via)),
            opts
        );
        lendResolver.setLendManager(proxy);

        console.log("LendResolver address: ", address(lendResolver));
        console.log("Deployed proxy to address", proxy);
    }
}
