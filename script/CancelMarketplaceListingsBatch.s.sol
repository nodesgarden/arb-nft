// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console2} from "forge-std/Script.sol";
import {NodeNFTMarketplace} from "../src/NodeNFTMarketplace.sol";
import {NodeNFTOperations} from "./utils/NodeNFTOperations.sol";

contract CancelMarketplaceListingsBatch is NodeNFTOperations {
    function run() external {
        address marketplaceAddress = vm.envAddress("MARKETPLACE_CONTRACT");
        uint256 sellerPrivateKey = vm.envUint("SELLER_PRIVATE_KEY");
        string memory filePath = vm.envString("MARKETPLACE_CANCELLATION_BATCH_FILE");

        NodeNFTMarketplace marketplace = NodeNFTMarketplace(marketplaceAddress);
        MarketplaceCancellationBatch memory batch = _readMarketplaceCancellationBatch(filePath);

        vm.startBroadcast(sellerPrivateKey);

        for (uint256 i = 0; i < batch.listingIds.length; ++i) {
            marketplace.cancelListing(batch.listingIds[i]);
        }

        vm.stopBroadcast();

        console2.log("Cancelled listings:", batch.listingIds.length);
        console2.log("Marketplace:", marketplaceAddress);
        console2.log("Batch file:", filePath);
    }
}
