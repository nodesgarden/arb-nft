// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {NodeNFT} from "./NodeNFT.sol";

contract NodeNFTMarketplace is ERC721Holder, ReentrancyGuard {
    error NodeNFTRequired();
    error PriceRequired();
    error SubscriptionExpired();
    error ListingInactive();
    error SellerRequired();
    error BuyerRequired();
    error WrongPrice();
    error TokenAlreadyListed();
    error PaymentFailed();

    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 priceWei;
        bool active;
    }

    NodeNFT public immutable NODE_NFT;

    uint256 private _nextListingId = 1;

    mapping(uint256 listingId => Listing listing) public listings;
    mapping(uint256 tokenId => uint256 listingId) public activeListingIdByTokenId;

    event ListingCreated(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, uint256 priceWei);
    event ListingCancelled(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller);
    event ListingPurchased(
        uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, address buyer, uint256 priceWei
    );

    constructor(address nodeNft_) {
        if (nodeNft_ == address(0)) revert NodeNFTRequired();

        NODE_NFT = NodeNFT(nodeNft_);
    }

    function createListing(uint256 tokenId, uint256 priceWei) external nonReentrant returns (uint256 listingId) {
        if (priceWei == 0) revert PriceRequired();
        if (activeListingIdByTokenId[tokenId] != 0) revert TokenAlreadyListed();

        (,, uint64 subscriptionExpiry) = NODE_NFT.nodeData(tokenId);
        if (subscriptionExpiry <= block.timestamp) revert SubscriptionExpired();

        listingId = _nextListingId++;
        listings[listingId] = Listing({tokenId: tokenId, seller: msg.sender, priceWei: priceWei, active: true});
        activeListingIdByTokenId[tokenId] = listingId;

        NODE_NFT.safeTransferFrom(msg.sender, address(this), tokenId);

        emit ListingCreated(listingId, tokenId, msg.sender, priceWei);
    }

    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        if (!listing.active) revert ListingInactive();
        if (listing.seller != msg.sender) revert SellerRequired();

        listing.active = false;
        activeListingIdByTokenId[listing.tokenId] = 0;

        NODE_NFT.safeTransferFrom(address(this), listing.seller, listing.tokenId);

        emit ListingCancelled(listingId, listing.tokenId, listing.seller);
    }

    function buy(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        if (!listing.active) revert ListingInactive();
        if (listing.seller == msg.sender) revert BuyerRequired();
        if (msg.value != listing.priceWei) revert WrongPrice();

        listing.active = false;
        activeListingIdByTokenId[listing.tokenId] = 0;

        (bool paid,) = listing.seller.call{value: msg.value}("");
        if (!paid) revert PaymentFailed();

        NODE_NFT.safeTransferFrom(address(this), msg.sender, listing.tokenId);

        emit ListingPurchased(listingId, listing.tokenId, listing.seller, msg.sender, msg.value);
    }
}
