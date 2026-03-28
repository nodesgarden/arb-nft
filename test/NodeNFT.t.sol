// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {NodeNFT} from "../src/NodeNFT.sol";

contract NodeNFTTest is Test {
    NodeNFT private nft;

    address private admin = address(0xA11CE);
    address private operator = address(0xB0B);
    address private user1 = address(0xCAFE);
    address private user2 = address(0xF00D);

    function setUp() public {
        nft = new NodeNFT("nodes.garden Node NFT", "NODE", admin, operator, "https://api.nodes.garden/nft/");
    }

    function testConstructorRejectsZeroAdmin() public {
        vm.expectRevert(AdminRequired.selector);
        new NodeNFT("nodes.garden Node NFT", "NODE", address(0), operator, "https://api.nodes.garden/nft/");
    }

    function testConstructorRejectsZeroOperator() public {
        vm.expectRevert(OperatorRequired.selector);
        new NodeNFT("nodes.garden Node NFT", "NODE", admin, address(0), "https://api.nodes.garden/nft/");
    }

    function testMintCreatesTokenAndData() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 25238, 1, uint64(block.timestamp + 30 days));

        assertEq(nft.ownerOf(tokenId), user1);
        (uint256 nodeId, uint32 nodeType, uint64 expiry) = nft.nodeData(tokenId);
        assertEq(nodeId, 25238);
        assertEq(nodeType, 1);
        assertGt(expiry, block.timestamp);
    }

    function testMintRequiresOperator() public {
        vm.expectRevert();
        nft.mint(user1, 1, 1, uint64(block.timestamp + 1 days));
    }

    function testMintRejectsDuplicateNodeId() public {
        vm.startPrank(operator);
        nft.mint(user1, 777, 1, uint64(block.timestamp + 1 days));
        vm.expectRevert();
        nft.mint(user2, 777, 1, uint64(block.timestamp + 2 days));
        vm.stopPrank();
    }

    function testMintRejectsZeroNodeType() public {
        vm.prank(operator);
        vm.expectRevert(NodeTypeRequired.selector);
        nft.mint(user1, 778, 0, uint64(block.timestamp + 1 days));
    }

    function testExtendSubscription() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 42, 2, uint64(block.timestamp + 1 days));

        uint64 newExpiry = uint64(block.timestamp + 30 days);
        vm.prank(operator);
        nft.extendSubscription(tokenId, newExpiry);

        (,, uint64 expiry) = nft.nodeData(tokenId);
        assertEq(expiry, newExpiry);
    }

    function testExtendSubscriptionRequiresOperator() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 43, 2, uint64(block.timestamp + 1 days));

        vm.expectRevert();
        nft.extendSubscription(tokenId, uint64(block.timestamp + 2 days));
    }

    function testExtendSubscriptionMustIncrease() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 44, 2, uint64(block.timestamp + 10 days));

        vm.prank(operator);
        vm.expectRevert();
        nft.extendSubscription(tokenId, uint64(block.timestamp + 5 days));
    }

    function testTokenURIUsesBaseURI() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 900, 3, uint64(block.timestamp + 10 days));

        assertEq(nft.tokenURI(tokenId), "https://api.nodes.garden/nft/1");
    }

    function testSetBaseURIRequiresAdmin() public {
        bytes32 adminRole = nft.DEFAULT_ADMIN_ROLE();

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, user1, adminRole));
        nft.setBaseURI("https://api.nodes.garden/v2/nft/");
    }

    function testSetBaseURIEmitsEventAndUpdatesTokenURI() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 901, 3, uint64(block.timestamp + 10 days));

        vm.prank(admin);
        vm.expectEmit(false, false, false, true);
        emit BaseURIUpdated("https://api.nodes.garden/nft/", "https://api.nodes.garden/v2/nft/");
        nft.setBaseURI("https://api.nodes.garden/v2/nft/");

        assertEq(nft.tokenURI(tokenId), "https://api.nodes.garden/v2/nft/1");
    }

    function testTokenIdByNodeIdReturnsMintedTokenId() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 902, 3, uint64(block.timestamp + 10 days));

        assertEq(nft.tokenIdByNodeId(902), tokenId);
    }

    function testNodeDataRejectsUnknownToken() public {
        vm.expectRevert(TokenNotMinted.selector);
        nft.nodeData(999);
    }

    function testTransferEmitsSyncEvent() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 501, 1, uint64(block.timestamp + 10 days));

        vm.prank(user1);
        vm.expectEmit(true, true, true, true);
        emit NodeTransferSync(501, user1, user2);
        nft.transferFrom(user1, user2, tokenId);
    }

    function testBurnIsDisabled() public {
        vm.prank(operator);
        uint256 tokenId = nft.mint(user1, 600, 1, uint64(block.timestamp + 10 days));

        vm.expectRevert(BurnDisabled.selector);
        nft.burn(tokenId);
    }

    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error AdminRequired();
    error OperatorRequired();
    error NodeTypeRequired();
    error TokenNotMinted();
    error BurnDisabled();

    event BaseURIUpdated(string oldBaseURI, string newBaseURI);
    event NodeTransferSync(uint256 indexed nodeId, address indexed from, address indexed to);
}
