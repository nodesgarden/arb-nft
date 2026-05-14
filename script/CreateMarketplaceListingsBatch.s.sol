// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console2} from "forge-std/Script.sol";
import {NodeNFT} from "../src/NodeNFT.sol";
import {NodeNFTMarketplace} from "../src/NodeNFTMarketplace.sol";
import {NodeNFTOperations} from "./utils/NodeNFTOperations.sol";

contract CreateMarketplaceListingsBatch is NodeNFTOperations {
    function run() external {
        address nftAddress = vm.envAddress("NFT_CONTRACT");
        address marketplaceAddress = vm.envAddress("MARKETPLACE_CONTRACT");
        uint256 ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        string memory filePath = vm.envString("MARKETPLACE_LISTING_BATCH_FILE");

        NodeNFT nft = NodeNFT(nftAddress);
        NodeNFTMarketplace marketplace = NodeNFTMarketplace(marketplaceAddress);
        MarketplaceListingBatch memory batch = _readMarketplaceListingBatch(filePath);

        vm.startBroadcast(ownerPrivateKey);

        for (uint256 i = 0; i < batch.tokenIds.length; ++i) {
            nft.approve(marketplaceAddress, batch.tokenIds[i]);
            marketplace.createListing(batch.tokenIds[i], batch.pricesWei[i]);
        }

        vm.stopBroadcast();

        console2.log("Created listings:", batch.tokenIds.length);
        console2.log("NFT contract:", nftAddress);
        console2.log("Marketplace:", marketplaceAddress);
        console2.log("Batch file:", filePath);
    }
}
