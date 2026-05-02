# Node NFT — nodes.garden

This repository contains the nodes.garden `NodeNFT` smart contract and the Milestone 2 testnet marketplace contract for Arbitrum Sepolia.
Each NFT represents a transferable node subscription access right while private node data and subscription lifecycle details remain off-chain.

Milestone 1 has been submitted to Arbitrum and accepted. The accepted deployment and operational evidence are recorded in [MILESTONE_1_EVIDENCE.md](MILESTONE_1_EVIDENCE.md).

## Contract Model

The NFT contract is intentionally minimal:

- ERC-721 token with role-gated minting and subscription extension
- `nodeId` stores the Rails `nodes.id`
- `nodeType` stores the Rails `project_id`
- `subscriptionExpiry` stores the current subscription `end_date` as a unix timestamp
- `tokenURI` resolves to `baseURI + tokenId`
- `NodeTransferSync` is emitted on transfers for backend indexing
- burn is intentionally disabled in Milestone 1

Tier selection, tariff plans, lifecycle status, pricing, and all private node credentials remain off-chain.

The Milestone 2 marketplace contract adds fixed-price native ETH escrow:

- sellers list active Node NFTs by transferring them into marketplace escrow
- sellers can cancel active listings and recover the NFT
- buyers purchase with exact native ETH, paying the seller directly
- Rails indexes marketplace events and applies backend ownership changes after confirmed purchase
- there is no protocol fee in Milestone 2

## Milestone 1 Scope

Included:

- Node NFT contract
- Foundry test suite
- Arbitrum Sepolia deployment and verification
- 100 testnet mints
- representative multi-wallet transfers
- public reviewer-facing documentation

Out of scope:

- marketplace functionality
- on-chain payments
- mainnet deployment
- burn-to-reveal flows
- upgradeability

## Milestone 2 Scope

Included:

- `NodeNFTMarketplace` fixed-price escrow contract
- native ETH payments on Arbitrum Sepolia
- listing, cancellation, and purchase events for Rails indexing
- Foundry tests for escrow, cancellation, purchase, and invalid state paths

Out of scope:

- protocol fees
- ERC-20 or stablecoin payments
- mainnet deployment
- public marketplace launch controls
- backend indexing and dashboard UI, which live in the `nodes.garden` Rails app

## Repository Guide

- [CONTRACT_SPEC.md](CONTRACT_SPEC.md) defines the canonical contract semantics
- [API.md](API.md) defines the off-chain metadata API contract
- [DEPLOYMENT.md](DEPLOYMENT.md) documents deployment and verification
- [MILESTONE_1_EVIDENCE.md](MILESTONE_1_EVIDENCE.md) records deployment and milestone proof

## Operational Scripts

The repo includes reproducible Foundry scripts for Milestone 1 operations:

- `script/DeployNodeNFT.s.sol` deploys the contract
- `script/DeployNodeNFTMarketplace.s.sol` deploys the marketplace for an existing `NodeNFT`
- `script/MintNodeNFTBatch.s.sol` performs operator-driven batch minting from a JSON file
- `script/TransferNodeNFTBatch.s.sol` performs owner-driven batch transfers from a JSON file

Example batch files live under `script/examples/`:

- `mint-batch.example.json`
- `transfer-batch.example.json`

## Tooling

- Foundry
- OpenZeppelin Contracts
- GitHub Actions for formatting, build, and tests

## Local Commands

Standard commands:

```sh
forge fmt --check
forge build
forge test
```

Targeted local verification:

```sh
forge test --offline --no-auto-detect --match-contract NodeNFTOperationsTest
```

If plain `forge test` crashes locally in some macOS environments, use:

```sh
forge test --offline --no-auto-detect
```

The CI workflow uses the standard command path. The offline variant is only a local workaround for environments where Foundry crashes during network-dependent signature lookup.

## Security Notes

- never commit private keys or RPC URLs
- keep deploy secrets in local environment variables
- validate batch input before broadcasting milestone operations
- metadata must never expose private keys, access tokens, or internal node data
