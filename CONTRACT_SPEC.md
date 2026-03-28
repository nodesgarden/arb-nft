# NodeNFT Contract Specification

## Purpose

`NodeNFT` is an ERC-721 contract for nodes.garden.
Each token represents a transferable subscription access right for a backend-managed node.

Milestone 1 keeps the on-chain model deliberately small. The contract is an ownership and expiry registry, not a full mirror of the Rails domain model.

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
