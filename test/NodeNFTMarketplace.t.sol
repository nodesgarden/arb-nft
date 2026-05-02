// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {NodeNFT} from "../src/NodeNFT.sol";
import {NodeNFTMarketplace} from "../src/NodeNFTMarketplace.sol";

contract NodeNFTMarketplaceTest is Test {
    NodeNFT private nft;
    NodeNFTMarketplace private marketplace;

    address private admin = address(0xA11CE);
    address private operator = address(0xB0B);
    address private seller = address(0xCAFE);
    address private buyer = address(0xF00D);
    address private stranger = address(0xBAD);

    uint256 private constant PRICE = 0.25 ether;

    function setUp() public {
        nft = new NodeNFT("nodes.garden Node NFT", "NODE", admin, operator, "https://api.nodes.garden/nft/");
        marketplace = new NodeNFTMarketplace(address(nft));

        vm.deal(seller, 10 ether);
        vm.deal(buyer, 10 ether);
        vm.deal(stranger, 10 ether);
    }

    function testCreateListingEscrowsNft() public {
        uint256 tokenId = mintToSeller(1);

        vm.prank(seller);
        nft.approve(address(marketplace), tokenId);

        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit ListingCreated(1, tokenId, seller, PRICE);
        uint256 listingId = marketplace.createListing(tokenId, PRICE);

        (uint256 listedTokenId, address listedSeller, uint256 listedPrice, bool active) =
            marketplace.listings(listingId);
        assertEq(listedTokenId, tokenId);
        assertEq(listedSeller, seller);
        assertEq(listedPrice, PRICE);
        assertTrue(active);
        assertEq(nft.ownerOf(tokenId), address(marketplace));
        assertEq(marketplace.activeListingIdByTokenId(tokenId), listingId);
    }

    function testCreateListingRejectsExpiredSubscription() public {
        uint256 tokenId = mintToSeller(1);
        vm.warp(block.timestamp + 31 days);

        vm.prank(seller);
        nft.approve(address(marketplace), tokenId);

        vm.prank(seller);
        vm.expectRevert(SubscriptionExpired.selector);
        marketplace.createListing(tokenId, PRICE);
    }

    function testCreateListingRejectsZeroPrice() public {
        uint256 tokenId = mintToSeller(1);

        vm.prank(seller);
        nft.approve(address(marketplace), tokenId);

        vm.prank(seller);
        vm.expectRevert(PriceRequired.selector);
        marketplace.createListing(tokenId, 0);
    }

    function testCancelListingReturnsNftToSeller() public {
        uint256 tokenId = mintToSeller(1);
        uint256 listingId = createListing(tokenId, PRICE);

        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit ListingCancelled(listingId, tokenId, seller);
        marketplace.cancelListing(listingId);

        (,,, bool active) = marketplace.listings(listingId);
        assertFalse(active);
        assertEq(nft.ownerOf(tokenId), seller);
        assertEq(marketplace.activeListingIdByTokenId(tokenId), 0);
    }

    function testCancelListingRejectsNonSeller() public {
        uint256 tokenId = mintToSeller(1);
        uint256 listingId = createListing(tokenId, PRICE);

        vm.prank(stranger);
        vm.expectRevert(SellerRequired.selector);
        marketplace.cancelListing(listingId);
    }

    function testBuyTransfersNftAndPaysSeller() public {
        uint256 tokenId = mintToSeller(1);
        uint256 listingId = createListing(tokenId, PRICE);
        uint256 sellerBalanceBefore = seller.balance;

        vm.prank(buyer);
        vm.expectEmit(true, true, true, true);
        emit ListingPurchased(listingId, tokenId, seller, buyer, PRICE);
        marketplace.buy{value: PRICE}(listingId);

        (,,, bool active) = marketplace.listings(listingId);
        assertFalse(active);
        assertEq(nft.ownerOf(tokenId), buyer);
        assertEq(seller.balance, sellerBalanceBefore + PRICE);
        assertEq(marketplace.activeListingIdByTokenId(tokenId), 0);
    }

    function testBuyRejectsWrongPrice() public {
        uint256 tokenId = mintToSeller(1);
        uint256 listingId = createListing(tokenId, PRICE);

        vm.prank(buyer);
        vm.expectRevert(WrongPrice.selector);
        marketplace.buy{value: PRICE - 1}(listingId);
    }

    function testBuyRejectsInactiveListing() public {
        uint256 tokenId = mintToSeller(1);
        uint256 listingId = createListing(tokenId, PRICE);

        vm.prank(seller);
        marketplace.cancelListing(listingId);

        vm.prank(buyer);
        vm.expectRevert(ListingInactive.selector);
        marketplace.buy{value: PRICE}(listingId);
    }

    function testBuyRejectsSeller() public {
        uint256 tokenId = mintToSeller(1);
        uint256 listingId = createListing(tokenId, PRICE);

        vm.prank(seller);
        vm.expectRevert(BuyerRequired.selector);
        marketplace.buy{value: PRICE}(listingId);
    }

    function testCreateListingRejectsAlreadyListedToken() public {
        uint256 tokenId = mintToSeller(1);
        createListing(tokenId, PRICE);

        vm.prank(seller);
        vm.expectRevert(TokenAlreadyListed.selector);
        marketplace.createListing(tokenId, PRICE);
    }

    function mintToSeller(uint256 nodeId) private returns (uint256 tokenId) {
        vm.prank(operator);
        tokenId = nft.mint(seller, nodeId, 1, uint64(block.timestamp + 30 days));
    }

    function createListing(uint256 tokenId, uint256 priceWei) private returns (uint256 listingId) {
        vm.prank(seller);
        nft.approve(address(marketplace), tokenId);

        vm.prank(seller);
        listingId = marketplace.createListing(tokenId, priceWei);
    }

    error PriceRequired();
    error SubscriptionExpired();
    error ListingInactive();
    error SellerRequired();
    error BuyerRequired();
    error WrongPrice();
    error TokenAlreadyListed();

    event ListingCreated(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, uint256 priceWei);
    event ListingCancelled(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller);
    event ListingPurchased(
        uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, address buyer, uint256 priceWei
    );
}
