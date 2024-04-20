// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "@ethereum-attestation-service/contracts/IEAS.sol";
import {ILendManager} from "./interfaces/ILendManager.sol";

contract ReFiMedLendResolver is SchemaResolver {
    address private _lendManager;

    constructor(IEAS eas) SchemaResolver(eas) {}

    function setLendManager(address lendManager) external {
        _lendManager = lendManager;
    }

    function onAttest(Attestation calldata attestation, uint256 /*value*/ ) internal override returns (bool) {
        (uint256 amount, address recipent, uint16 index) = abi.decode(attestation.data, (uint256, address, uint16));
        bool success = ILendManager(_lendManager).increaseQuota(recipent, index, attestation.attester);
        if (success) {
            return true;
        }
        return false;
    }

    function onRevoke(Attestation calldata, /*attestation*/ uint256 /*value*/ ) internal pure override returns (bool) {
        return true;
    }
}
