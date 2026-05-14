// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, stdJson} from "forge-std/Script.sol";

abstract contract NodeNFTOperations is Script {
    using stdJson for string;

    error BatchLengthMismatch();
    error EmptyBatch();
    error NodeTypeOutOfRange(uint256 nodeType);
    error PriceRequired();
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

    struct MarketplaceListingBatch {
        uint256[] tokenIds;
        uint256[] pricesWei;
    }

    struct MarketplaceBuyBatch {
        uint256[] listingIds;
        uint256[] pricesWei;
    }

    struct MarketplaceCancellationBatch {
        uint256[] listingIds;
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

    function _readMarketplaceListingBatch(string memory filePath)
        internal
        view
        returns (MarketplaceListingBatch memory batch)
    {
        string memory json = vm.readFile(filePath);

        batch.tokenIds = json.readUintArray(".tokenIds");
        batch.pricesWei = json.readUintArray(".pricesWei");

        _requireSameLength(batch.tokenIds.length, batch.pricesWei.length);

        if (batch.tokenIds.length == 0) revert EmptyBatch();
        _requirePositivePrices(batch.pricesWei);
    }

    function _readMarketplaceBuyBatch(string memory filePath) internal view returns (MarketplaceBuyBatch memory batch) {
        string memory json = vm.readFile(filePath);

        batch.listingIds = json.readUintArray(".listingIds");
        batch.pricesWei = json.readUintArray(".pricesWei");

        _requireSameLength(batch.listingIds.length, batch.pricesWei.length);

        if (batch.listingIds.length == 0) revert EmptyBatch();
        _requirePositivePrices(batch.pricesWei);
    }

    function _readMarketplaceCancellationBatch(string memory filePath)
        internal
        view
        returns (MarketplaceCancellationBatch memory batch)
    {
        string memory json = vm.readFile(filePath);

        batch.listingIds = json.readUintArray(".listingIds");

        if (batch.listingIds.length == 0) revert EmptyBatch();
    }

    function _requireSameLength(uint256 expected, uint256 actual) internal pure {
        if (expected != actual) revert BatchLengthMismatch();
    }

    function _requirePositivePrices(uint256[] memory pricesWei) private pure {
        for (uint256 i = 0; i < pricesWei.length; ++i) {
            if (pricesWei[i] == 0) revert PriceRequired();
        }
    }
}
