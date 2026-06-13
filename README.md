# Node NFT — nodes.garden

This repository contains the nodes.garden `NodeNFT` smart contract and the fixed-price `NodeNFTMarketplace` contract.
Each NFT represents a transferable node subscription access right while private node data and subscription lifecycle details remain off-chain.

Milestone 1 has been submitted to Arbitrum and accepted. The accepted deployment and operational evidence are recorded in [MILESTONE_1_EVIDENCE.md](MILESTONE_1_EVIDENCE.md).

Current state as of the latest handoff:

- `NodeNFT` Milestone 1 is deployed on Arbitrum Sepolia and accepted by Arbitrum.
- `NodeNFTMarketplace` Milestone 2 contract is implemented locally in this repo with Foundry tests.
- `NodeNFTMarketplace` is deployed and verified on Arbitrum Sepolia at `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`.
- The Rails marketplace backend/UI/indexer foundation is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Target Rails env configuration, live sync, and KPI proof generation are completed: `303` listing-created events and `101` purchase events indexed.
- Milestone 2 submission package is ready in [MILESTONE_2_SUBMISSION.md](MILESTONE_2_SUBMISSION.md).
- Milestone 3 signed mint and burn-to-reveal contract changes are merged into `main`.
- Milestone 3 Rails mint/burn integration is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PRs #265-#270.
- Fresh Milestone 3 contracts are deployed and verified on Arbitrum Sepolia for rehearsal:
  - `NodeNFT`: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
  - `NodeNFTMarketplace`: `0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`

## Contract Model

The NFT contract is intentionally minimal:

- ERC-721 token with role-gated minting and subscription extension
- `nodeId` stores the Rails `nodes.id`
- `nodeType` stores the Rails `project_id`
- `subscriptionExpiry` stores the current subscription `end_date` as a unix timestamp
- `tokenURI` resolves to `baseURI + tokenId`
- `NodeTransferSync` is emitted on transfers for backend indexing
- burn is enabled in Milestone 3 for `Burn to Reveal Key`

Tier selection, tariff plans, lifecycle status, pricing, and all private node credentials remain off-chain.

The Milestone 2 marketplace contract adds fixed-price native ETH escrow:

- sellers list active Node NFTs by transferring them into marketplace escrow
- sellers can cancel active listings and recover the NFT
- buyers purchase with exact native ETH, paying the seller directly
- Rails indexes marketplace events and applies backend ownership changes after confirmed purchase
- there is no protocol fee in Milestone 2

The Milestone 3 contract update adds the mainnet launch flow:

- Rails signs an EIP-712 `MintAuthorization`
- users pay gas and call `mintWithSignature` from their wallet
- burn emits `NodeBurned`, which Rails indexes before revealing private node keys
- burned node ids cannot be re-minted

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
- Rails-side indexing/dashboard foundation in `nodes.garden` main

Out of scope:

- protocol fees
- ERC-20 or stablecoin payments
- mainnet deployment
- public marketplace launch controls

## Milestone 3 Scope

Included:

- signed user-paid minting
- burn-to-reveal event support
- Arbitrum Sepolia rehearsal deployment and smoke script
- Arbitrum mainnet deployment scripts
- Rails mint/burn dashboard integration in `nodes.garden`
- project-gated mintability for newly purchased nodes
- hidden private data for new mintable nodes until NFT mint or explicit reveal
- post-purchase mint prompt, pending-state explanation, and mint-ready in-app notification
- tester-only demo activation path for making waiting demo nodes mint-ready

Still pending:

- real browser Sepolia UI smoke across purchase prompt, demo activation, mint, list, buy, burn, and sync confirmation
- Arbitrum mainnet deployment
- production Rails mainnet env configuration
- controlled cohort onboarding
- KPI tracking for mints, trades, and contract-interacting MAUs

## Repository Guide

- [CONTRACT_SPEC.md](CONTRACT_SPEC.md) defines the canonical contract semantics
- [API.md](API.md) defines the off-chain metadata API contract
- [DEPLOYMENT.md](DEPLOYMENT.md) documents deployment and verification
- [MILESTONE_1_EVIDENCE.md](MILESTONE_1_EVIDENCE.md) records deployment and milestone proof
- [MILESTONE_2_EVIDENCE.md](MILESTONE_2_EVIDENCE.md) records marketplace deployment proof and KPI evidence
- [MILESTONE_2_SUBMISSION.md](MILESTONE_2_SUBMISSION.md) is the reviewer-facing Milestone 2 summary
- [PROGRESS.md](PROGRESS.md) is the current handoff checklist

## Operational Scripts

The repo includes reproducible Foundry scripts for milestone operations:

- `script/DeployNodeNFT.s.sol` deploys the contract
- `script/DeployNodeNFTMarketplace.s.sol` deploys the marketplace for an existing `NodeNFT`
- `script/SmokeTestMilestone3Sepolia.s.sol` runs the Sepolia mint/list/cancel/burn rehearsal
- `script/MintNodeNFTBatch.s.sol` performs operator-driven batch minting from a JSON file
- `script/TransferNodeNFTBatch.s.sol` performs owner-driven batch transfers from a JSON file
- `script/CreateMarketplaceListingsBatch.s.sol` approves and lists owned NFTs from a JSON file
- `script/BuyMarketplaceListingsBatch.s.sol` buys listings from a JSON file
- `script/CancelMarketplaceListingsBatch.s.sol` cancels seller listings from a JSON file

Example batch files live under `script/examples/`:

- `mint-batch.example.json`
- `transfer-batch.example.json`
- `marketplace-listings.example.json`
- `marketplace-buys.example.json`
- `marketplace-cancellations.example.json`

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
- Rails marketplace routes are intentionally hidden behind a hardcoded tester allowlist for Milestone 2
- Rails ownership transfer must happen only after confirmed on-chain purchase events are indexed

## Rails Work Completed In `nodes.garden`

The Rails app has the Milestone 2 marketplace foundation merged into `main` via PR #264:

- persisted listings, events, and sync cursor
- `NodeNft` owner-address sync fields
- idempotent event applier for create/cancel/purchase/transfer events
- JSON-RPC log syncer and GoodJob cron hook
- gated dashboard UI at `/dashboard/marketplace`
- MetaMask transaction flow for list, cancel, and buy
- transaction prep/status endpoints under `/dashboard/marketplace`

The Rails app also has the Milestone 3 mint/burn user flow merged into `main` via PRs #265-#270:

- contract-deployment-scoped Node NFT state
- project-level NFT mintability toggle
- new mintable node purchases start with hidden private data
- legacy and relaunched nodes keep existing key visibility behavior
- dashboard `Mint Node NFT`, `Burn to Reveal Key`, and non-minted `Reveal keys` flows
- post-purchase NFT prompt for hidden nodes
- pending explanation while a hidden node is not yet active/exportable
- in-app notification when a hidden node becomes ready to mint
- tester-only demo activation service for waiting demo nodes

Recorded verification from the marketplace branch:

```sh
rbenv exec bundle exec rspec
rbenv exec bundle exec rubocop app/models/node_nft.rb app/models/nft_marketplace app/services/nft_marketplace.rb app/services/nft_marketplace app/jobs/nft_marketplace app/controllers/dashboard/marketplace_controller.rb spec/models/node_nft_spec.rb spec/services/nft_marketplace spec/requests/dashboard/marketplace_spec.rb
npm run build
```

Latest results:

- RSpec: `446 examples, 0 failures, 3 pending`
- targeted RuboCop: no offenses
- JS build: passed

Latest `arb-nft` verification before resuming deployment:

```sh
forge fmt --check
forge build
forge test --offline --no-auto-detect
```

Result: `39 tests passed, 0 failed`.
