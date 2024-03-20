// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "@ethereum-attestation-service/contracts/IEAS.sol";
import {ILendManager} from "./interfaces/ILendManager.sol";

contract LendResolver is SchemaResolver {
    struct QuotaRequest {
        uint256 amount;
        address recipent;
        uint16 index;
    }

    address private _lendManager;

    constructor(IEAS eas) SchemaResolver(eas) {}

    function setLendManager(address lendManager) external {
        _lendManager = lendManager;
    }

    function onAttest(Attestation calldata attestation, uint256 /*value*/ ) internal override returns (bool) {
        QuotaRequest memory quotaRequest = abi.decode(attestation.data, (QuotaRequest));
        bool success =
            ILendManager(_lendManager)._increaseQuota(quotaRequest.recipent, quotaRequest.index, attestation.attester);
        if (success) {
            return true;
        }
        return false;
    }

    function onRevoke(Attestation calldata, /*attestation*/ uint256 /*value*/ ) internal pure override returns (bool) {
        return true;
    }
}
