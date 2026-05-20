# NodeNFT Contract Specification

## Purpose

`NodeNFT` is an ERC-721 contract for nodes.garden.
Each token represents a transferable subscription access right for a backend-managed node.

Milestone 1 kept the NFT model deliberately small. The contract is an ownership and expiry registry, not a full mirror of the Rails domain model.

Milestone 2 adds `NodeNFTMarketplace`, a separate fixed-price escrow contract for Arbitrum Sepolia testnet marketplace proof.

Milestone 3 adds signed user-paid minting and burn-to-reveal support for the mainnet launch flow.

Implementation state:

- `NodeNFT` is deployed and accepted for Milestone 1.
- `NodeNFTMarketplace` is implemented, deployed, and verified on Arbitrum Sepolia at `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`.
- Rails marketplace indexing/UI is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 3 contract changes are implemented on `feat/milestone-3-contracts`.
- Milestone 3 Rails integration is implemented on `/Users/ilyalebedev/projects/nodes.garden` branch `feat/milestone-3-rails`.
- Fresh Milestone 3 Sepolia contracts are deployed and verified:
  - `NodeNFT`: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
  - `NodeNFTMarketplace`: `0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`

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
- `MINT_AUTHORIZER_ROLE`
  - signs EIP-712 mint authorizations for user-paid mints

The intended operational model is:

- admin = long-lived control wallet or multisig later
- operator = hot wallet used by nodes.garden operational backend
- mint authorizer = signing wallet used by Rails to authorize `mintWithSignature`

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

### Signed Minting

`mintWithSignature(MintAuthorization authorization, bytes signature)`

Milestone 3 uses this function for user-paid minting from the nodes.garden dashboard after an off-chain purchase has created an exportable node.

`MintAuthorization` fields:

- `to`: wallet that will receive the NFT
- `nodeId`: Rails `nodes.id`
- `nodeType`: Rails `nodes.project_id`
- `subscriptionExpiry`: current subscription expiry as a unix timestamp
- `nonce`: one-time `bytes32`
- `deadline`: unix timestamp after which the authorization is invalid

Rules:

- `deadline` must not be expired
- `nonce` must not have been used
- recovered signer must have `MINT_AUTHORIZER_ROLE` or `OPERATOR_ROLE`
- all normal mint validation rules still apply

Effects:

- marks the nonce used
- mints the NFT to `authorization.to`
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

`burn(uint256 tokenId)`

Milestone 1 disabled burn. Milestone 3 enables burn for the dashboard `Burn to Reveal Key` flow.

Rules:

- token must exist
- caller must be token owner or an approved operator

Effects:

- deletes token data
- clears the `nodeId -> tokenId` lookup
- marks the `nodeId` burned so it cannot be minted again
- burns the ERC-721 token
- emits `NodeBurned`

## Events

- `BaseURIUpdated(string oldBaseURI, string newBaseURI)`
- `NodeMinted(uint256 indexed tokenId, uint256 indexed nodeId, address indexed to)`
- `NodeBurned(uint256 indexed tokenId, uint256 indexed nodeId, address indexed owner)`
- `SubscriptionExtended(uint256 indexed tokenId, uint64 oldExpiry, uint64 newExpiry)`
- `NodeTransferSync(uint256 indexed nodeId, address indexed from, address indexed to)`

## Errors

Custom errors are used for contract-owned validation paths:

- `AdminRequired()`
- `OperatorRequired()`
- `MintAuthorizerRequired()`
- `ToRequired()`
- `NodeIdRequired()`
- `NodeTypeRequired()`
- `ExpiryInPast()`
- `NodeAlreadyMinted()`
- `TokenNotMinted()`
- `ExpiryNotExtended()`
- `MintAuthorizationExpired()`
- `MintNonceUsed()`
- `MintSignerUnauthorized()`

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

## Off-Chain Marketplace Contract

The Rails app is the operational indexer and product surface. It does not create marketplace state optimistically. It waits for confirmed on-chain logs.

Rails records:

- `nft_marketplace_listings`
  - `listing_id`
  - `token_id`
  - `node_nft_id`
  - `seller_address`
  - `buyer_address`
  - `price_wei`
  - `status`: `active`, `cancelled`, `purchased`
  - create/cancel/purchase tx hashes and block numbers
- `nft_marketplace_events`
  - event type
  - listing id
  - token id
  - seller/buyer addresses
  - price
  - tx hash
  - log index
  - block metadata
  - raw log
- `nft_marketplace_sync_cursors`
  - network
  - contract address
  - last processed block
- `node_nfts`
  - network
  - mint status: `mint_pending`, `minted`, `keys_revealed`
  - `owner_address`
  - key reveal/burn timestamps
  - last synced block and tx
- `node_nft_mint_authorizations`
  - node id
  - network
  - wallet address
  - nonce
  - deadline
  - signature
  - used timestamp

Rails event handling:

- `ListingCreated`
  - creates or updates an active listing
  - links to `NodeNft` when the token exists locally
  - records seller and price
- `ListingCancelled`
  - marks the listing cancelled
- `ListingPurchased`
  - marks the listing purchased
  - finds or creates the buyer user by wallet address
  - transfers Rails `Node#user` to the buyer
  - updates `NodeNft.owner_address`
- `NodeTransferSync`
  - updates `NodeNft.owner_address`
- `NodeMinted`
  - creates or updates `NodeNft`
  - sets `mint_status` to `minted`
  - records owner address and sync metadata
  - marks the matching mint authorization used
- `NodeBurned`
  - sets `mint_status` to `keys_revealed`
  - locks the NFT state from marketplace eligibility
  - records burn tx and reveal timestamps

Rails listing eligibility:

- current user must be in the hardcoded tester allowlist
- node must belong to the current user
- node must have a known `NodeNft`
- Rails `NodeNft.owner_address` must match the current user's wallet
- node subscription must be active

Milestone 3 semantics now included:

- signed user-paid minting
- burn-to-reveal event path
- Sepolia/mainnet network-scoped indexing

Still out of scope:

- no public launch
- no protocol fee
- no subscription renewal payment flow
- no ERC-20 or stablecoin marketplace payments
