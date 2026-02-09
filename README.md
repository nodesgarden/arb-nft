# Node NFT — nodes.garden (Arbitrum Testnet)

This repository contains the **Node NFT** smart contract for nodes.garden.  
Each node subscription can be represented by an ERC-721 NFT on **Arbitrum Sepolia**, enabling transferability while keeping private node data off-chain.

## What This Contract Does
- **ERC-721 Node NFT** representing a node subscription.
- **Operator-controlled minting** (nodes.garden hot wallet).
- **Subscription extension** via operator updates (after off-chain payment).
- **On-chain minimal metadata**:
  - `nodeId` (uint256, DB id)
  - `nodeType` (uint32, type id)
  - `subscriptionExpiry` (uint64, unix timestamp)
- **tokenURI** points to nodes.garden API for dynamic metadata.
- **Transfer sync event** emitted on ownership transfers for backend indexing.
- **Burn disabled** in this milestone (stubbed for later).

## Off-Chain Design
Private node data (keys, access credentials, logs) **never** goes on-chain.  
The NFT acts as a transferable access right; when burn is enabled in a later milestone, it will allow revealing private data from the nodes.garden backend.

## Milestone Scope
This repo is focused on **Milestone 1**:
- Node NFT contract (testnet deployment)
- Internal test suite
- Documentation

Marketplace, mainnet deployment, and burn-to-reveal are **out of scope** for this milestone.

## Security Notes
- No secrets are stored in the repo.
- Do not commit private keys or RPC URLs.
- Use `.env` for local development when needed.

## Tooling
Built with **Foundry** and **OpenZeppelin Contracts**.

## Basic Commands

```sh
forge build
forge test
forge fmt
```
