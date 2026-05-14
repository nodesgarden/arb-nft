// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console2} from "forge-std/Script.sol";
import {NodeNFTMarketplace} from "../src/NodeNFTMarketplace.sol";
import {NodeNFTOperations} from "./utils/NodeNFTOperations.sol";

contract BuyMarketplaceListingsBatch is NodeNFTOperations {
    function run() external {
        address marketplaceAddress = vm.envAddress("MARKETPLACE_CONTRACT");
        uint256 buyerPrivateKey = vm.envUint("BUYER_PRIVATE_KEY");
        string memory filePath = vm.envString("MARKETPLACE_BUY_BATCH_FILE");

        NodeNFTMarketplace marketplace = NodeNFTMarketplace(marketplaceAddress);
        MarketplaceBuyBatch memory batch = _readMarketplaceBuyBatch(filePath);

        vm.startBroadcast(buyerPrivateKey);

        for (uint256 i = 0; i < batch.listingIds.length; ++i) {
            marketplace.buy{value: batch.pricesWei[i]}(batch.listingIds[i]);
        }

        vm.stopBroadcast();

        console2.log("Purchased listings:", batch.listingIds.length);
        console2.log("Marketplace:", marketplaceAddress);
        console2.log("Batch file:", filePath);
    }
}
