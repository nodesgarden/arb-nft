# AGENTS.md

This file provides guidance when working with code in this repository.

## Project Overview

Node NFT smart contract suite for nodes.garden on Arbitrum Sepolia. `NodeNFT` is an ERC-721 NFT representing node subscriptions with operator-controlled minting and subscription extensions. `NodeNFTMarketplace` is a Milestone 2 fixed-price escrow marketplace for active Node NFTs. Private node data stays off-chain; the NFT is a transferable access right.

Current handoff state:
- Milestone 1 `NodeNFT` was deployed, verified, submitted to Arbitrum, and accepted.
- Milestone 2 marketplace contract and Foundry tests are implemented in this repo.
- Rails marketplace backend/UI/indexer foundation is implemented in `/Users/ilyalebedev/projects/nodes.garden`.
- Milestone 2 contracts still need Arbitrum Sepolia deployment, Rails env configuration, demo data, and KPI event generation.

## Build & Test Commands

```sh
forge build          # Compile contracts
forge test           # Run all tests
forge test -vvv      # Run tests with verbose output
forge test --match-test testFunctionName  # Run single test
forge fmt            # Format Solidity code
forge coverage       # Generate test coverage
```

## Architecture

### Contract: `src/NodeNFT.sol`
- Inherits ERC721 + AccessControl from OpenZeppelin
- **Roles**: `DEFAULT_ADMIN_ROLE` (admin), `OPERATOR_ROLE` (hot wallet for minting/extending)
- **On-chain data per token**: `nodeId` (uint256), `nodeType` (uint32), `subscriptionExpiry` (uint64)
- **tokenURI**: baseURI + tokenId → points to nodes.garden API for dynamic metadata
- **Events**: `NodeMinted`, `SubscriptionExtended`, `NodeTransferSync` (emitted on transfers for backend indexing)
- **Burn**: Disabled in Milestone 1 (reverts with `BurnDisabled()`)

### Key Mappings
- `_nodeDataByTokenId`: tokenId → NodeData struct
- `_tokenIdByNodeId`: nodeId (DB id) → tokenId (for lookups)

### Contract: `src/NodeNFTMarketplace.sol`
- Inherits `ERC721Holder` + `ReentrancyGuard`
- Escrows listed `NodeNFT` tokens
- `createListing(tokenId, priceWei)` creates an active listing and transfers NFT into escrow
- `cancelListing(listingId)` returns the NFT to the seller
- `buy(listingId)` requires exact native ETH, pays seller, transfers NFT to buyer
- No protocol fee in Milestone 2
- Emits `ListingCreated`, `ListingCancelled`, and `ListingPurchased`

### Rails Integration: `/Users/ilyalebedev/projects/nodes.garden`
- Tables: `nft_marketplace_listings`, `nft_marketplace_events`, `nft_marketplace_sync_cursors`
- `node_nfts` tracks `owner_address`, `last_synced_block_number`, and `last_synced_tx_hash`
- `NftMarketplace::SyncJob` polls Arbitrum Sepolia logs through JSON-RPC and applies events idempotently
- Dashboard route: `/dashboard/marketplace`, gated by hardcoded tester IDs `[1]`
- MetaMask frontend prepares calls through `/dashboard/marketplace/transaction`
- Purchase event transfers Rails `Node#user` to the buyer wallet user

### Dependencies (via git submodules in `lib/`)
- `forge-std` — Foundry test utilities
- `openzeppelin-contracts` — ERC721, AccessControl

### Remappings
`@openzeppelin/` → `lib/openzeppelin-contracts/`

## Target Network

Arbitrum Sepolia (testnet). Deployment scripts go in `script/`.

## Resume Checklist

1. Deploy `NodeNFTMarketplace` with `script/DeployNodeNFTMarketplace.s.sol`.
2. Set Rails env:
   - `ARB_SEPOLIA_RPC_URL`
   - `NODE_NFT_CONTRACT_ADDRESS`
   - `NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS`
   - `NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK`
3. Run Rails migrations in `nodes.garden`.
4. Enable `GOOD_JOB_ENABLE_CRON=true` or enqueue `NftMarketplace::SyncJob` manually.
5. Create production/staging demo users and update the hardcoded tester list if needed.
6. Generate KPI evidence: `>=300` listing-created events and `>=100` buy/sell events.
