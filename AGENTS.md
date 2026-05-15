# AGENTS.md

This file provides guidance when working with code in this repository.

## Project Overview

Node NFT smart contract suite for nodes.garden on Arbitrum Sepolia. `NodeNFT` is an ERC-721 NFT representing node subscriptions with operator-controlled minting and subscription extensions. `NodeNFTMarketplace` is a Milestone 2 fixed-price escrow marketplace for active Node NFTs. Private node data stays off-chain; the NFT is a transferable access right.

Current handoff state:
- Milestone 1 `NodeNFT` was deployed, verified, submitted to Arbitrum, and accepted.
- Milestone 2 marketplace contract and Foundry tests are implemented in this repo.
- `NodeNFTMarketplace` is deployed and verified on Arbitrum Sepolia at `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`.
- Rails marketplace backend/UI/indexer foundation is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 2 target Rails env configuration, live sync, production UI test, and KPI event generation are completed.
- Milestone 2 submission package is ready in `MILESTONE_2_SUBMISSION.md`.

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

### KPI Batch Scripts
- `script/CreateMarketplaceListingsBatch.s.sol` reads `MARKETPLACE_LISTING_BATCH_FILE` and uses `OWNER_PRIVATE_KEY`
- `script/BuyMarketplaceListingsBatch.s.sol` reads `MARKETPLACE_BUY_BATCH_FILE` and uses `BUYER_PRIVATE_KEY`
- `script/CancelMarketplaceListingsBatch.s.sol` reads `MARKETPLACE_CANCELLATION_BATCH_FILE` and uses `SELLER_PRIVATE_KEY`
- Example JSON files live in `script/examples/`

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

1. Set Rails env:
   - `ARB_SEPOLIA_RPC_URL`
   - `NODE_NFT_CONTRACT_ADDRESS`
   - `NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS`
   - `NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK`
2. Apply marketplace Rails migration in the target env if not already applied.
3. Enable `GOOD_JOB_ENABLE_CRON=true` if relying on cron, or enqueue `NftMarketplace::SyncJob` manually.
4. Create/select target-env demo tester users and update the hardcoded tester list if needed.
5. Use `MILESTONE_2_SUBMISSION.md` and `MILESTONE_2_EVIDENCE.md` for reviewer submission.
