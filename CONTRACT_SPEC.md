# NodeNFT Contract Specification

## Purpose

`NodeNFT` is an ERC-721 contract for nodes.garden.
Each token represents a transferable subscription access right for a backend-managed node.

Milestone 1 keeps the NFT model deliberately small. The contract is an ownership and expiry registry, not a full mirror of the Rails domain model.

Milestone 2 adds `NodeNFTMarketplace`, a separate fixed-price escrow contract for Arbitrum Sepolia testnet marketplace proof.

## Canonical Field Mapping

The on-chain `NodeData` struct maps to backend data as follows:

- `nodeId`: Rails `nodes.id`
- `nodeType`: Rails `nodes.project_id`
- `subscriptionExpiry`: current subscription `end_date` as a unix timestamp

Milestone 1 does not store `tier_id`, tariff plan, lifecycle state, or pricing on-chain.

## Roles

- `DEFAULT_ADMIN_ROLE`
  - controls admin-only functions such as `setBaseURI`
- `OPERATOR_ROLE`
  - mints NFTs
  - extends subscriptions after off-chain payment or admin workflow

The intended operational model is:

- admin = long-lived control wallet or multisig later
- operator = hot wallet used by nodes.garden operational backend

## Contract Behavior

### Minting

`mint(address to, uint256 nodeId, uint32 nodeType, uint64 subscriptionExpiry)`

Rules:

- caller must have `OPERATOR_ROLE`
- `to` must be non-zero
- `nodeId` must be non-zero
- `nodeType` must be non-zero
- `subscriptionExpiry` must be in the future
- each `nodeId` may only be minted once

Effects:

- assigns a new sequential token id starting from `1`
- stores `NodeData`
- maps `nodeId -> tokenId`
- mints the ERC-721 token
- emits `NodeMinted`

### Subscription Extension

`extendSubscription(uint256 tokenId, uint64 newExpiry)`

Rules:

- caller must have `OPERATOR_ROLE`
- token must exist
- `newExpiry` must be greater than current expiry
- `newExpiry` must still be in the future

Effects:

- updates `subscriptionExpiry`
- emits `SubscriptionExtended`

### Metadata

`tokenURI(tokenId)` resolves to:

- `baseURI + tokenId`

`setBaseURI(string newBaseURI)`:

- admin-only
- updates the metadata base URI
- emits `BaseURIUpdated`

### Transfers

Standard ERC-721 transfers are allowed.
On every non-mint, non-burn ownership transfer, the contract emits `NodeTransferSync(nodeId, from, to)` for backend indexing.

### Burn

`burn(uint256)` always reverts in Milestone 1.

This is intentional. Burn-to-reveal or other burn flows are out of scope for this milestone.

## Events

- `BaseURIUpdated(string oldBaseURI, string newBaseURI)`
- `NodeMinted(uint256 indexed tokenId, uint256 indexed nodeId, address indexed to)`
- `SubscriptionExtended(uint256 indexed tokenId, uint64 oldExpiry, uint64 newExpiry)`
- `NodeTransferSync(uint256 indexed nodeId, address indexed from, address indexed to)`

## Errors

Custom errors are used for contract-owned validation paths:

- `AdminRequired()`
- `OperatorRequired()`
- `ToRequired()`
- `NodeIdRequired()`
- `NodeTypeRequired()`
- `ExpiryInPast()`
- `NodeAlreadyMinted()`
- `TokenNotMinted()`
- `ExpiryNotExtended()`
- `BurnDisabled()`

OpenZeppelin access-control reverts still apply for unauthorized role usage.

## What Stays Off-Chain

The following remain off-chain by design:

- node credentials
- host and infrastructure details
- lifecycle state
- tier selection
- tariff plan details
- pricing and payment history
- internal support metadata

That data lives in the nodes.garden backend and is exposed selectively through the public metadata API where appropriate.

## NodeNFTMarketplace

`NodeNFTMarketplace` lists active `NodeNFT` tokens for native ETH. It is intentionally separate from `NodeNFT` so the NFT contract remains minimal and already-minted tokens do not need migration.

### Constructor

`constructor(address nodeNFT_)`

Rules:

- `nodeNFT_` must be non-zero
- the referenced contract must expose the `NodeNFT` ERC-721 and `nodeData` interface

### Listing Creation

`createListing(uint256 tokenId, uint256 priceWei) returns (uint256 listingId)`

Rules:

- `priceWei` must be greater than zero
- the token must not already have an active listing
- the token subscription expiry from `NodeNFT.nodeData(tokenId)` must be in the future
- the caller must own the token or the underlying ERC-721 transfer reverts
- the marketplace must be approved to transfer the token

Effects:

- creates the next sequential listing id starting from `1`
- records seller, token id, price, and active status
- maps `tokenId -> active listing id`
- transfers the NFT from seller into marketplace escrow
- emits `ListingCreated`

### Listing Cancellation

`cancelListing(uint256 listingId)`

Rules:

- listing must be active
- caller must be the recorded seller

Effects:

- marks the listing inactive
- clears the active listing lookup for the token
- transfers the NFT back to the seller
- emits `ListingCancelled`

### Purchase

`buy(uint256 listingId) payable`

Rules:

- listing must be active
- buyer must not be the seller
- `msg.value` must exactly equal the listing price

Effects:

- marks the listing inactive
- clears the active listing lookup for the token
- pays the seller directly in native ETH
- transfers the NFT from marketplace escrow to the buyer
- emits `ListingPurchased`

There is no protocol fee in Milestone 2.

### Marketplace Events

- `ListingCreated(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, uint256 priceWei)`
- `ListingCancelled(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller)`
- `ListingPurchased(uint256 indexed listingId, uint256 indexed tokenId, address indexed seller, address buyer, uint256 priceWei)`

### Marketplace Errors

- `NodeNFTRequired()`
- `PriceRequired()`
- `SubscriptionExpired()`
- `ListingInactive()`
- `SellerRequired()`
- `BuyerRequired()`
- `WrongPrice()`
- `TokenAlreadyListed()`
- `PaymentFailed()`
