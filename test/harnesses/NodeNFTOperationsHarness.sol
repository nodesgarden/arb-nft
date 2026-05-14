// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {NodeNFTOperations} from "../../script/utils/NodeNFTOperations.sol";

contract NodeNFTOperationsHarness is NodeNFTOperations {
    function readMintBatch(string memory filePath)
        external
        view
        returns (
            address[] memory recipients,
            uint256[] memory nodeIds,
            uint256[] memory nodeTypes,
            uint256[] memory subscriptionExpiries
        )
    {
        MintBatch memory batch = _readMintBatch(filePath);
        return (batch.recipients, batch.nodeIds, batch.nodeTypes, batch.subscriptionExpiries);
    }

    function readTransferBatch(string memory filePath)
        external
        view
        returns (address[] memory recipients, uint256[] memory tokenIds)
    {
        TransferBatch memory batch = _readTransferBatch(filePath);
        return (batch.recipients, batch.tokenIds);
    }

    function readMarketplaceListingBatch(string memory filePath)
        external
        view
        returns (uint256[] memory tokenIds, uint256[] memory pricesWei)
    {
        MarketplaceListingBatch memory batch = _readMarketplaceListingBatch(filePath);
        return (batch.tokenIds, batch.pricesWei);
    }

    function readMarketplaceBuyBatch(string memory filePath)
        external
        view
        returns (uint256[] memory listingIds, uint256[] memory pricesWei)
    {
        MarketplaceBuyBatch memory batch = _readMarketplaceBuyBatch(filePath);
        return (batch.listingIds, batch.pricesWei);
    }

    function readMarketplaceCancellationBatch(string memory filePath)
        external
        view
        returns (uint256[] memory listingIds)
    {
        MarketplaceCancellationBatch memory batch = _readMarketplaceCancellationBatch(filePath);
        return batch.listingIds;
    }
}
