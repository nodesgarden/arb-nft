// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {NodeNFT} from "../src/NodeNFT.sol";

contract DeployNodeNFT is Script {
    function run() external returns (NodeNFT deployed) {
        address admin = vm.envAddress("ADMIN_ADDRESS");
        address operator = vm.envAddress("OPERATOR_ADDRESS");
        string memory name = vm.envString("NFT_NAME");
        string memory symbol = vm.envString("NFT_SYMBOL");
        string memory baseUri = vm.envString("BASE_URI");

        vm.startBroadcast();
        deployed = new NodeNFT(name, symbol, admin, operator, baseUri);
        vm.stopBroadcast();
    }
}
