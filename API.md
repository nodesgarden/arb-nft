# Metadata API Contract

`NodeNFT.tokenURI(tokenId)` returns `BASE_URI + tokenId`.
The metadata endpoint behind that URL is the public source used by wallets, marketplaces, and explorers.

Current Rails handoff:

- metadata still lives in the `nodes.garden` Rails app
- marketplace dashboard/API endpoints now also live in `nodes.garden`
- marketplace actions are prepared by Rails but executed directly from the user's wallet
- Rails state updates only after confirmed Arbitrum Sepolia events are indexed

## Endpoint

- `GET /api/nft/:token_id`

Example:

- `https://nodes.garden/api/nft/1`

## Backend Mapping

The metadata API must map contract data to the Rails backend exactly:

- `token_id`: ERC-721 token id
- `node_id`: Rails `nodes.id`
- `node_type`: Rails `nodes.project_id`
- `subscription_expiry`: current subscription `end_date` expressed as a unix timestamp
- `status`: derived off-chain from backend node and subscription state

`nodeType` is not an abstract enum in Milestone 1. It is the backend `project_id`.

## Required JSON Shape

```json
{
  "name": "nodes.garden Node #<token_id>",
  "description": "Node subscription NFT for nodes.garden.",
  "image": "https://.../nft/<token_id>.png",
  "attributes": [
    { "trait_type": "node_id", "value": 25238 },
    { "trait_type": "node_type", "value": 117 },
    { "trait_type": "subscription_expiry", "display_type": "date", "value": 1767225600 },
    { "trait_type": "status", "value": "active" }
  ]
}
```

## Field Semantics

- `name`: stable display name for the NFT
- `description`: human-readable description of the access right
- `image`: stable public HTTPS URL
- `node_id`: backend node id
- `node_type`: backend project id
- `subscription_expiry`: expiry timestamp in seconds
- `status`: off-chain status string, such as `waiting`, `active`, `paused`, `expired`, or `cancelled`

## Data Source Rules

- nodes.garden database is the primary source of truth
- no private node credentials may be returned
- metadata may be updated dynamically as the off-chain state changes
- `token_id -> node_id` should be recorded at mint time from the `NodeMinted(tokenId, nodeId, to)` event

## Response Behavior

- `token_id` must be a positive integer
- unknown `token_id` should return `404`
- responses should be public and cacheable
- short cache duration is preferred because status and expiry can change

## Security Notes

- never expose private keys, access tokens, or internal host data
- do not encode backend-only secrets into image URLs or metadata attributes
- treat the endpoint as fully public

## Marketplace Rails Endpoints

These are not smart-contract APIs. They are Rails dashboard helpers used by the Milestone 2 UI in `/Users/ilyalebedev/projects/nodes.garden`.

Routes:

- `GET /dashboard/marketplace`
- `GET /dashboard/marketplace/transaction`
- `GET /dashboard/marketplace/status`

Access:

- hidden from non-testers
- hardcoded tester allowlist currently starts as user ID `[1]`
- the sidebar link renders only for allowed users

Transaction preparation:

- `action_type=create_listing`
  - requires `token_id`
  - requires positive integer `price_wei`
  - Rails verifies the node belongs to the current user
  - Rails verifies the `NodeNft` has a known on-chain `owner_address` matching the current user's wallet
  - Rails verifies the node subscription is active
- `action_type=cancel_listing`
  - requires `listing_id`
  - Rails verifies the active listing seller matches the current user's wallet
- `action_type=buy`
  - requires `listing_id`
  - Rails rejects buying your own listing

Returned JSON includes:

- `chain_id`: `0x66eee`
- `chain_name`: `Arbitrum Sepolia`
- `contract_address`: marketplace contract address from Rails env
- `method`: one of `createListing`, `cancelListing`, `buy`
- `args`: contract call args as strings
- `value`: native ETH value in wei as a string
- `marketplace_abi`: minimal ethers ABI for the frontend

Required Rails env:

- `ARB_SEPOLIA_RPC_URL`
- `NODE_NFT_CONTRACT_ADDRESS`
- `NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS`
- `NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK`

Indexer behavior:

- `NftMarketplace::SyncJob` polls `ListingCreated`, `ListingCancelled`, `ListingPurchased`, and `NodeTransferSync`
- events are stored idempotently by `tx_hash + log_index`
- purchase events find or create the buyer by wallet address and transfer Rails `Node#user` to that buyer
