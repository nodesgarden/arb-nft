// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {NodeNFT} from "../src/NodeNFT.sol";
import {NodeNFTMarketplace} from "../src/NodeNFTMarketplace.sol";

contract SmokeTestMilestone3Sepolia is Script {
    bytes32 private constant MINT_AUTHORIZATION_TYPEHASH = keccak256(
        "MintAuthorization(address to,uint256 nodeId,uint32 nodeType,uint64 subscriptionExpiry,bytes32 nonce,uint64 deadline)"
    );
    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function run() external {
        uint256 ownerPrivateKey = vm.envUint("OWNER_PRIVATE_KEY");
        uint256 mintAuthorizerPrivateKey = vm.envUint("MINT_AUTHORIZER_PRIVATE_KEY");
        address owner = vm.addr(ownerPrivateKey);
        address mintAuthorizer = vm.addr(mintAuthorizerPrivateKey);
        NodeNFT nodeNft = NodeNFT(vm.envAddress("NFT_CONTRACT"));
        NodeNFTMarketplace marketplace = NodeNFTMarketplace(vm.envAddress("MARKETPLACE_CONTRACT"));

        uint256 nodeId = uint256(keccak256(abi.encodePacked(block.timestamp, owner))) % 1_000_000_000;
        if (nodeId == 0) {
            nodeId = 1;
        }

        NodeNFT.MintAuthorization memory authorization = NodeNFT.MintAuthorization({
            to: owner,
            nodeId: nodeId,
            nodeType: 117,
            subscriptionExpiry: uint64(block.timestamp + 30 days),
            nonce: keccak256(abi.encodePacked("milestone-3-smoke", block.timestamp, owner)),
            deadline: uint64(block.timestamp + 1 hours)
        });

        bytes memory signature = _sign(nodeNft, authorization, mintAuthorizerPrivateKey);

        vm.startBroadcast(ownerPrivateKey);
        uint256 tokenId = nodeNft.mintWithSignature(authorization, signature);
        nodeNft.approve(address(marketplace), tokenId);
        uint256 listingId = marketplace.createListing(tokenId, 0.001 ether);
        marketplace.cancelListing(listingId);
        nodeNft.burn(tokenId);
        vm.stopBroadcast();

        console2.log("smoke owner", owner);
        console2.log("smoke mintAuthorizer", mintAuthorizer);
        console2.log("smoke nodeId", nodeId);
        console2.log("smoke tokenId", tokenId);
        console2.log("smoke listingId", listingId);
    }

    function _sign(NodeNFT nodeNft, NodeNFT.MintAuthorization memory authorization, uint256 privateKey)
        private
        view
        returns (bytes memory signature)
    {
        bytes32 structHash = keccak256(
            abi.encode(
                MINT_AUTHORIZATION_TYPEHASH,
                authorization.to,
                authorization.nodeId,
                authorization.nodeType,
                authorization.subscriptionExpiry,
                authorization.nonce,
                authorization.deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", _domainSeparator(nodeNft), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        signature = abi.encodePacked(r, s, v);
    }

    function _domainSeparator(NodeNFT nodeNft) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes("nodes.garden Node NFT")),
                keccak256(bytes("1")),
                block.chainid,
                address(nodeNft)
            )
        );
    }
}
