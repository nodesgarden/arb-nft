# AGENTS.md

This file provides guidance when working with code in this repository.

## Project Overview

Node NFT smart contract for nodes.garden on Arbitrum Sepolia. ERC-721 NFT representing node subscriptions with operator-controlled minting and subscription extensions. Private node data stays off-chain; the NFT is a transferable access right.

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
- **Burn**: Disabled in Milestone 1 (reverts with `BURN_DISABLED`)

### Key Mappings
- `_nodeDataByTokenId`: tokenId → NodeData struct
- `_tokenIdByNodeId`: nodeId (DB id) → tokenId (for lookups)

### Dependencies (via git submodules in `lib/`)
- `forge-std` — Foundry test utilities
- `openzeppelin-contracts` — ERC721, AccessControl

### Remappings
`@openzeppelin/` → `lib/openzeppelin-contracts/`

## Target Network

Arbitrum Sepolia (testnet). Deployment scripts go in `script/`.
