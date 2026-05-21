# Metadata API Contract

`NodeNFT.tokenURI(tokenId)` returns `BASE_URI + tokenId`.
The metadata endpoint behind that URL is the public source used by wallets, marketplaces, and explorers.

Current Rails handoff:

- metadata still lives in the `nodes.garden` Rails app
- marketplace dashboard/API endpoints now live in `nodes.garden` `main` via PR #264
- marketplace actions are prepared by Rails but executed directly from the user's wallet
- Rails state updates only after confirmed Arbitrum events are indexed
- deployed marketplace contract: `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
- Milestone 3 mint/burn dashboard endpoints are implemented in `nodes.garden` branch `feat/milestone-3-rails`
- Milestone 3 Sepolia rehearsal contracts:
  - `NodeNFT`: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
  - `NodeNFTMarketplace`: `0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`

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
- `NODE_NFT_CONTRACT_ADDRESS=0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- `NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS=0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
- `NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK=268201592`

Indexer behavior:

- `NftMarketplace::SyncJob` polls `ListingCreated`, `ListingCancelled`, `ListingPurchased`, and `NodeTransferSync`
- events are stored idempotently by `tx_hash + log_index`
- purchase events find or create the buyer by wallet address and transfer Rails `Node#user` to that buyer

## Milestone 3 Node NFT Rails Endpoints

These endpoints are implemented in `nodes.garden` branch `feat/milestone-3-rails`.
They prepare browser wallet transactions; Rails never broadcasts user wallet transactions itself.

Routes:

- `GET /dashboard/nodes/:id/nft_mint_authorization`
- `GET /dashboard/nodes/:id/nft_burn_transaction`

Access:

- current dashboard user must own the node
- connected wallet must match `current_user.wallet_address`
- minting is only available for exportable nodes that contain key material
- existing non-NFT nodes keep the old data behavior
- NFT-backed nodes hide private key and mnemonic fields until a confirmed `NodeBurned` event is indexed

Mint transaction preparation:

- Rails validates the node has an active subscription
- Rails rejects nodes that are already minted or keys-revealed
- Rails creates or updates `NodeNft` as `mint_pending`
- Rails creates `NodeNftMintAuthorization`
- Rails signs EIP-712 `MintAuthorization`
- returned method is `mintWithSignature`

Mint returned JSON includes:

- `chain_id`
- `chain_name`
- `contract_address`: `NodeNFT` address
- `method`: `mintWithSignature`
- `args`: `[authorizationTuple, signature]`
- `value`: `0`
- `node_nft_abi`: minimal ethers ABI

Burn transaction preparation:

- Rails requires an existing minted `NodeNft`
- Rails verifies `NodeNft.owner_address` matches the current user's wallet
- returned method is `burn`
- returned args contain `token_id`

Milestone 3 Sepolia Rails env:

- `NFT_MARKETPLACE_NETWORK=arbitrum_sepolia`
- `ARB_SEPOLIA_RPC_URL`
- `ARB_SEPOLIA_WALLET_RPC_URL`
- `NODE_NFT_CONTRACT_ADDRESS=0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
- `NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS=0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`
- `NODE_NFT_DEPLOYMENT_BLOCK=269610905`
- `NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK=269611269`
- `NODE_NFT_MINT_AUTHORIZER_PRIVATE_KEY`

Milestone 3 mainnet Rails env:

- `NFT_MARKETPLACE_NETWORK=arbitrum_mainnet`
- `ARB_MAINNET_RPC_URL`
- `ARB_MAINNET_WALLET_RPC_URL`
- `NODE_NFT_MAINNET_CONTRACT_ADDRESS`
- `NODE_NFT_MAINNET_MARKETPLACE_CONTRACT_ADDRESS`
- `NODE_NFT_MAINNET_DEPLOYMENT_BLOCK`
- `NODE_NFT_MAINNET_MARKETPLACE_DEPLOYMENT_BLOCK`
- `NODE_NFT_MAINNET_MINT_AUTHORIZER_PRIVATE_KEY`
