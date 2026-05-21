// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {NodeNFT} from "../src/NodeNFT.sol";

contract NodeNFTMainnetMintBurnTest is Test {
    NodeNFT private nft;

    string private constant NFT_NAME = "nodes.garden Node NFT";
    bytes32 private constant MINT_AUTHORIZATION_TYPEHASH = keccak256(
        "MintAuthorization(address to,uint256 nodeId,uint32 nodeType,uint64 subscriptionExpiry,bytes32 nonce,uint64 deadline)"
    );
    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    uint256 private mintAuthorizerKey = 0xA11CE;
    uint256 private unauthorizedSignerKey = 0xBEEF;
    address private admin = address(0xA11CE);
    address private operator = address(0xB0B);
    address private mintAuthorizer;
    address private user1 = address(0xCAFE);
    address private user2 = address(0xF00D);

    function setUp() public {
        mintAuthorizer = vm.addr(mintAuthorizerKey);
        nft = new NodeNFT(NFT_NAME, "NODE", admin, operator, mintAuthorizer, "https://api.nodes.garden/nft/");
    }

    function testMintWithSignatureMintsToRequestedWallet() public {
        NodeNFT.MintAuthorization memory authorization =
            _authorization(user1, 25238, 117, uint64(block.timestamp + 30 days), "mint-1");

        vm.expectEmit(true, true, true, true);
        emit NodeMinted(1, 25238, user1);
        uint256 tokenId = nft.mintWithSignature(authorization, _sign(authorization, mintAuthorizerKey));

        assertEq(tokenId, 1);
        assertEq(nft.ownerOf(tokenId), user1);
        assertTrue(nft.usedMintNonces(authorization.nonce));

        (uint256 nodeId, uint32 nodeType, uint64 expiry) = nft.nodeData(tokenId);
        assertEq(nodeId, authorization.nodeId);
        assertEq(nodeType, authorization.nodeType);
        assertEq(expiry, authorization.subscriptionExpiry);
        assertEq(nft.tokenIdByNodeId(authorization.nodeId), tokenId);
    }

    function testMintWithSignatureRejectsChangedWallet() public {
        NodeNFT.MintAuthorization memory authorization =
            _authorization(user1, 25239, 117, uint64(block.timestamp + 30 days), "mint-2");
        bytes memory signature = _sign(authorization, mintAuthorizerKey);
        authorization.to = user2;

        vm.expectRevert(MintSignerUnauthorized.selector);
        nft.mintWithSignature(authorization, signature);
    }

    function testMintWithSignatureRejectsNonceReplay() public {
        NodeNFT.MintAuthorization memory authorization =
            _authorization(user1, 25240, 117, uint64(block.timestamp + 30 days), "mint-3");
        bytes memory signature = _sign(authorization, mintAuthorizerKey);

        nft.mintWithSignature(authorization, signature);

        vm.expectRevert(MintNonceUsed.selector);
        nft.mintWithSignature(authorization, signature);
    }

    function testMintWithSignatureRejectsExpiredAuthorization() public {
        NodeNFT.MintAuthorization memory authorization =
            _authorization(user1, 25241, 117, uint64(block.timestamp + 30 days), "mint-4");
        authorization.deadline = uint64(block.timestamp - 1);

        vm.expectRevert(MintAuthorizationExpired.selector);
        nft.mintWithSignature(authorization, _sign(authorization, mintAuthorizerKey));
    }

    function testMintWithSignatureRejectsUnauthorizedSigner() public {
        NodeNFT.MintAuthorization memory authorization =
            _authorization(user1, 25242, 117, uint64(block.timestamp + 30 days), "mint-5");

        vm.expectRevert(MintSignerUnauthorized.selector);
        nft.mintWithSignature(authorization, _sign(authorization, unauthorizedSignerKey));
    }

    function testMintWithSignatureKeepsMintValidation() public {
        NodeNFT.MintAuthorization memory authorization =
            _authorization(address(0), 25243, 117, uint64(block.timestamp + 30 days), "mint-6");
        vm.expectRevert(ToRequired.selector);
        nft.mintWithSignature(authorization, _sign(authorization, mintAuthorizerKey));

        authorization = _authorization(user1, 0, 117, uint64(block.timestamp + 30 days), "mint-7");
        vm.expectRevert(NodeIdRequired.selector);
        nft.mintWithSignature(authorization, _sign(authorization, mintAuthorizerKey));

        authorization = _authorization(user1, 25244, 0, uint64(block.timestamp + 30 days), "mint-8");
        vm.expectRevert(NodeTypeRequired.selector);
        nft.mintWithSignature(authorization, _sign(authorization, mintAuthorizerKey));

        authorization = _authorization(user1, 25245, 117, uint64(block.timestamp - 1), "mint-9");
        vm.expectRevert(ExpiryInPast.selector);
        nft.mintWithSignature(authorization, _sign(authorization, mintAuthorizerKey));
    }

    function testOwnerCanBurnToReveal() public {
        uint256 tokenId = _operatorMint(user1, 700, 117);

        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit NodeBurned(tokenId, 700, user1);
        nft.burn(tokenId);

        assertEq(nft.tokenIdByNodeId(700), 0);
        vm.expectRevert();
        nft.ownerOf(tokenId);
        vm.expectRevert(TokenNotMinted.selector);
        nft.nodeData(tokenId);
    }

    function testApprovedOperatorCanBurnToReveal() public {
        uint256 tokenId = _operatorMint(user1, 701, 117);

        vm.prank(user1);
        nft.approve(user2, tokenId);

        vm.prank(user2);
        vm.expectEmit(true, true, true, true);
        emit NodeBurned(tokenId, 701, user1);
        nft.burn(tokenId);

        assertEq(nft.tokenIdByNodeId(701), 0);
    }

    function testUnrelatedWalletCannotBurnToReveal() public {
        uint256 tokenId = _operatorMint(user1, 702, 117);

        vm.prank(user2);
        vm.expectRevert();
        nft.burn(tokenId);
    }

    function testBurnedNodeIdCannotBeReminted() public {
        uint256 tokenId = _operatorMint(user1, 703, 117);

        vm.prank(user1);
        nft.burn(tokenId);

        vm.prank(operator);
        vm.expectRevert(NodeAlreadyMinted.selector);
        nft.mint(user2, 703, 117, uint64(block.timestamp + 30 days));
    }

    function _operatorMint(address to, uint256 nodeId, uint32 nodeType) private returns (uint256 tokenId) {
        vm.prank(operator);
        tokenId = nft.mint(to, nodeId, nodeType, uint64(block.timestamp + 30 days));
    }

    function _authorization(address to, uint256 nodeId, uint32 nodeType, uint64 expiry, string memory nonceSeed)
        private
        view
        returns (NodeNFT.MintAuthorization memory)
    {
        return NodeNFT.MintAuthorization({
            to: to,
            nodeId: nodeId,
            nodeType: nodeType,
            subscriptionExpiry: expiry,
            nonce: keccak256(bytes(nonceSeed)),
            deadline: uint64(block.timestamp + 1 days)
        });
    }

    function _sign(NodeNFT.MintAuthorization memory authorization, uint256 privateKey)
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
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        signature = abi.encodePacked(r, s, v);
    }

    function _domainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH, keccak256(bytes(NFT_NAME)), keccak256(bytes("1")), block.chainid, address(nft)
            )
        );
    }

    error MintAuthorizationExpired();
    error MintNonceUsed();
    error MintSignerUnauthorized();
    error ToRequired();
    error NodeIdRequired();
    error NodeTypeRequired();
    error ExpiryInPast();
    error NodeAlreadyMinted();
    error TokenNotMinted();

    event NodeMinted(uint256 indexed tokenId, uint256 indexed nodeId, address indexed to);
    event NodeBurned(uint256 indexed tokenId, uint256 indexed nodeId, address indexed owner);
}
