// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console2} from "forge-std/Script.sol";
import {NodeNFT} from "../src/NodeNFT.sol";
import {NodeNFTOperations} from "./utils/NodeNFTOperations.sol";

contract MintNodeNFTBatch is NodeNFTOperations {
    function run() external {
        address contractAddress = vm.envAddress("NFT_CONTRACT");
        uint256 operatorPrivateKey = vm.envUint("OPERATOR_PRIVATE_KEY");
        string memory filePath = vm.envString("MINT_BATCH_FILE");

        NodeNFT nft = NodeNFT(contractAddress);
        MintBatch memory batch = _readMintBatch(filePath);

        vm.startBroadcast(operatorPrivateKey);

        for (uint256 i = 0; i < batch.recipients.length; ++i) {
            nft.mint(
                batch.recipients[i], batch.nodeIds[i], uint32(batch.nodeTypes[i]), uint64(batch.subscriptionExpiries[i])
            );
        }

        vm.stopBroadcast();

        console2.log("Minted tokens:", batch.recipients.length);
        console2.log("Contract:", contractAddress);
        console2.log("Batch file:", filePath);
    }
}
