# Progress — Node NFT Milestones

## Current Status

- Milestone 1: completed, submitted to Arbitrum, and accepted.
- Milestone 2 contract: implemented, deployed, and verified on Arbitrum Sepolia.
- Milestone 2 Rails backend/UI/indexer: merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 2 target Rails env configuration, live sync, and KPI on-chain proof: completed.
- Milestone 2 submission package: ready.

## Milestone 2 Completed Locally

In this repo:

1. [x] Implement `NodeNFTMarketplace` fixed-price escrow contract.
2. [x] Add listing creation, cancellation, and purchase flows.
3. [x] Add native ETH seller payout with no protocol fee.
4. [x] Add active-subscription check through `NodeNFT.nodeData`.
5. [x] Add duplicate active listing protection.
6. [x] Add Foundry tests for create/cancel/buy/reject paths.
7. [x] Add deployment script for marketplace contract.
8. [x] Add KPI batch scripts for create-listing, buy, and cancel operations.
9. [x] Update contract/deployment docs.

In `nodes.garden`:

1. [x] Add marketplace listings/events/cursor tables.
2. [x] Add `owner_address` and sync metadata to `node_nfts`.
3. [x] Add idempotent event applier.
4. [x] Add JSON-RPC log decoder and syncer.
5. [x] Add GoodJob `NftMarketplace::SyncJob`.
6. [x] Add gated dashboard route `/dashboard/marketplace`.
7. [x] Add transaction preparation/status endpoints.
8. [x] Add Stimulus/MetaMask list/cancel/buy flow.
9. [x] Add sidebar link for allowed tester users.
10. [x] Add tests for event application, syncer, model behavior, and dashboard access.

Recorded `nodes.garden` verification from the marketplace branch:

- `rbenv exec bundle exec rspec`: `446 examples, 0 failures, 3 pending`
- targeted RuboCop: no offenses
- `npm run build`: passed

Latest `arb-nft` verification:

- `forge fmt --check`: passed
- `forge build`: passed
- `forge test --offline --no-auto-detect`: `39 tests passed, 0 failed`

## Milestone 2 Submission Readiness

1. [x] Deploy `NodeNFTMarketplace` on Arbitrum Sepolia.
2. [x] Verify marketplace contract on Arbiscan.
3. [x] Configure Rails env with contract addresses and deployment block.
4. [x] Apply marketplace migration in the target Rails env if not already applied.
5. [x] Run live sync and confirm indexed events.
6. [x] Generate `>=300` listing-created events.
7. [x] Generate `>=100` buy/sell events.
8. [x] Record tx hashes, indexed counts, and final evidence package.
9. [x] Record final production UI list/purchase test.

Marketplace deployment evidence: [MILESTONE_2_EVIDENCE.md](MILESTONE_2_EVIDENCE.md)
Submission summary: [MILESTONE_2_SUBMISSION.md](MILESTONE_2_SUBMISSION.md)

## Historical Progress — Milestone 1 (Node NFT Smart Contract)

Status: completed, submitted to Arbitrum, and accepted.

Canonical evidence: [MILESTONE_1_EVIDENCE.md](MILESTONE_1_EVIDENCE.md)

## Steps
1. [x] Confirm requirements and finalize plan scope.
2. [x] Select stack and tooling (Foundry + OpenZeppelin).
3. [x] Initialize contract project structure.
4. [x] Define contract specification (fields, roles, functions, events).
5. [x] Implement ERC-721 Node NFT contract.
6. [x] Implement access control and operator flow.
7. [x] Implement subscription extension logic.
8. [x] Implement metadata and tokenURI logic.
9. [x] Add transfer sync event with nodeId.
10. [x] Stub burn function for future milestone.
11. [x] Write unit tests for core flows.
12. [x] Run tests and fix issues.
13. [x] Prepare deployment script for Arbitrum Sepolia.
14. [x] Deploy and verify contract on Arbitrum Sepolia.
15. [x] Document contract usage and metadata format.
16. [x] Execute 100+ testnet mints and multi-wallet transfers.
17. [x] Final review against milestone success criteria.
18. [x] Submit Milestone 1 to Arbitrum and receive acceptance.
