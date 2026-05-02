// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {NodeNFTMarketplace} from "../src/NodeNFTMarketplace.sol";

contract DeployNodeNFTMarketplace is Script {
    function run() external returns (NodeNFTMarketplace deployed) {
        address nodeNft = vm.envAddress("NFT_CONTRACT");

        vm.startBroadcast();
        deployed = new NodeNFTMarketplace(nodeNft);
        vm.stopBroadcast();
    }
}
