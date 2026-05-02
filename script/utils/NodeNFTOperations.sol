// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, stdJson} from "forge-std/Script.sol";

abstract contract NodeNFTOperations is Script {
    using stdJson for string;

    error BatchLengthMismatch();
    error EmptyBatch();
    error NodeTypeOutOfRange(uint256 nodeType);
    error SubscriptionExpiryOutOfRange(uint256 subscriptionExpiry);

    struct MintBatch {
        address[] recipients;
        uint256[] nodeIds;
        uint256[] nodeTypes;
        uint256[] subscriptionExpiries;
    }

    struct TransferBatch {
        address[] recipients;
        uint256[] tokenIds;
    }

    function _readMintBatch(string memory filePath) internal view returns (MintBatch memory batch) {
        string memory json = vm.readFile(filePath);

        batch.recipients = json.readAddressArray(".recipients");
        batch.nodeIds = json.readUintArray(".nodeIds");
        batch.nodeTypes = json.readUintArray(".nodeTypes");
        batch.subscriptionExpiries = json.readUintArray(".subscriptionExpiries");

        _requireSameLength(batch.recipients.length, batch.nodeIds.length);
        _requireSameLength(batch.recipients.length, batch.nodeTypes.length);
        _requireSameLength(batch.recipients.length, batch.subscriptionExpiries.length);

        if (batch.recipients.length == 0) revert EmptyBatch();

        for (uint256 i = 0; i < batch.recipients.length; ++i) {
            if (batch.nodeTypes[i] > type(uint32).max) revert NodeTypeOutOfRange(batch.nodeTypes[i]);
            if (batch.subscriptionExpiries[i] > type(uint64).max) {
                revert SubscriptionExpiryOutOfRange(batch.subscriptionExpiries[i]);
            }
        }
    }

    function _readTransferBatch(string memory filePath) internal view returns (TransferBatch memory batch) {
        string memory json = vm.readFile(filePath);

        batch.recipients = json.readAddressArray(".recipients");
        batch.tokenIds = json.readUintArray(".tokenIds");

        _requireSameLength(batch.recipients.length, batch.tokenIds.length);

        if (batch.recipients.length == 0) revert EmptyBatch();
    }

    function _requireSameLength(uint256 expected, uint256 actual) internal pure {
        if (expected != actual) revert BatchLengthMismatch();
    }
}
