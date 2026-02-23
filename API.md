# API Requirements (nodes.garden)

This contract expects an off-chain metadata API for ERC-721 token metadata. The smart contract returns `tokenURI = BASE_URI + tokenId`.

## Endpoint
- `GET /api/nft/:token_id`

## Purpose
Return ERC-721 metadata JSON for a given `token_id`. This is used by wallets, marketplaces, and explorers to display the NFT.

## Data Source
- **Primary source of truth: nodes.garden DB**
- No on-chain calls required for metadata rendering.
- You should map `token_id -> node_id` in your DB at mint time.
- The `token_id` is emitted in the `NodeMinted(tokenId, nodeId, to)` event from the mint transaction.

## Required JSON Format
Return a JSON object with these fields:

```json
{
  "name": "nodes.garden Node #<token_id>",
  "description": "Node subscription NFT for nodes.garden.",
  "image": "https://.../nft/<token_id>.png",
  "attributes": [
    { "trait_type": "node_id", "value": 25238 },
    { "trait_type": "node_type", "value": 1 },
    { "trait_type": "subscription_expiry", "display_type": "date", "value": 1767225600 },
    { "trait_type": "status", "value": "active" }
  ]
}
```

## Fields
- `node_id`: integer (DB id)
- `node_type`: integer (type id)
- `subscription_expiry`: unix timestamp (seconds)
- `status`: string (e.g., `waiting`, `active`, `paused`, `expired`, `cancelled`)
- `image`: stable HTTPS URL

## Behavior
- `token_id` must be a positive integer.
- If `token_id` is unknown, return `404`.
- Response must be public and cacheable (recommended: short cache like 1–5 minutes).

## Security
- Never return private keys, access tokens, or internal node data.
- Metadata should be safe for public consumption.

## Notes
- You can update metadata dynamically as subscription state changes.
- The contract only stores `nodeId`, `nodeType`, and `subscriptionExpiry` on-chain.
