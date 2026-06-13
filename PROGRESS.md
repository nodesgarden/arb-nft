# Progress — Node NFT Milestones

## Current Status

- Milestone 1: completed, submitted to Arbitrum, and accepted.
- Milestone 2 contract: implemented, deployed, and verified on Arbitrum Sepolia.
- Milestone 2 Rails backend/UI/indexer: merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 2 target Rails env configuration, live sync, and KPI on-chain proof: completed.
- Milestone 2 submission package: ready.
- Milestone 3 contracts: merged into `arb-nft` `main`.
- Milestone 3 Rails integration: merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PRs #265-#270.
- Milestone 3 Sepolia rehearsal contracts: deployed, verified, and smoke-tested.

## Milestone 3 Completed Locally

In this repo:

1. [x] Add EIP-712 `MintAuthorization` struct and typehash.
2. [x] Add `MINT_AUTHORIZER_ROLE`.
3. [x] Add `mintWithSignature` for user-paid mints after off-chain purchase.
4. [x] Keep `OPERATOR_ROLE` minting for backend/operator workflows.
5. [x] Track used mint nonces.
6. [x] Enable owner/approved burn for burn-to-reveal.
7. [x] Emit `NodeBurned(tokenId, nodeId, owner)`.
8. [x] Prevent re-minting a burned `nodeId`.
9. [x] Add Foundry tests for signed mint and burn flows.
10. [x] Add mainnet deployment scripts.
11. [x] Add Sepolia smoke script for mint/list/cancel/burn.
12. [x] Deploy and verify fresh Milestone 3 Sepolia `NodeNFT`.
13. [x] Deploy and verify fresh Milestone 3 Sepolia `NodeNFTMarketplace`.
14. [x] Run Sepolia smoke script successfully.

In `nodes.garden` `main`:

1. [x] Add network-aware Sepolia/mainnet marketplace config.
2. [x] Scope marketplace listings/events/cursors by network.
3. [x] Add `node_nfts` lifecycle fields.
4. [x] Add `node_nft_mint_authorizations`.
5. [x] Index `NodeMinted`, `NodeBurned`, and `NodeTransferSync`.
6. [x] Mark mint authorizations used after confirmed `NodeMinted`.
7. [x] Set `keys_revealed` after confirmed `NodeBurned`.
8. [x] Hide private key/mnemonic fields until burn reveal.
9. [x] Add `Mint Node NFT` dashboard action.
10. [x] Add `Burn to Reveal Key` dashboard action.
11. [x] Chunk RPC log sync ranges.
12. [x] Configure local Rails `.env` for Sepolia smoke testing.
13. [x] Add project-level NFT mintability gating for new node purchases.
14. [x] Hide key material for newly purchased mintable nodes until NFT mint or explicit reveal.
15. [x] Prompt hidden nodes to mint as Node NFTs after purchase.
16. [x] Keep hidden, not-yet-active nodes visible in the NFT card with a pending explanation.
17. [x] Add in-app mint-ready notifications when hidden nodes become active/exportable.
18. [x] Add tester-only demo activation for waiting demo nodes to become mint-ready.
19. [x] Cover stale-instance duplicate notification and unrelated-save performance cases in specs.

Latest verification:

- `arb-nft`: `forge fmt --check`, `forge build`, and `forge test --offline --no-auto-detect` are the required pre-PR checks.
- `nodes.garden`: full RSpec for PR #270 passed with `516 examples, 0 failures, 3 pending`.
- `nodes.garden`: PR #270 GitHub checks passed for `rspec` and `rubocop`.
- `nodes.garden`: `npm run build` passed.
- `nodes.garden`: local Rails sync against Sepolia indexed smoke events after chunked log sync.

## Milestone 3 Sepolia Deployment Evidence

`NodeNFT`:

- address: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
- deployment tx: `0xeebe17b06d6f83727a4e9b5c657d935b09c8aed73dbd19f6faec480486db8626`
- deployment block: `269610905`
- explorer: `https://sepolia.arbiscan.io/address/0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F#code`

`NodeNFTMarketplace`:

- address: `0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`
- deployment tx: `0x6fb15f13c6b0d371b9e9b8f31bf5e3d345c2ee8d63cf3dfc8bd617eddea58920`
- deployment block: `269611269`
- explorer: `https://sepolia.arbiscan.io/address/0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0#code`

Smoke transaction sequence:

- mint: `0x72171f19be419535a1e7e3e92b88e8df4f5978a7c380cc9b13fe2dc5b6cdfb89`
- approve marketplace: `0x021c7981d5b99bf3c20dcb9444b928bce1bb207de6f197161e1bd23b3b95a472`
- list: `0x622c14da0eb30065f465562ea0bb29116e962221a06710466a97b5dcf3ef2d8f`
- cancel listing: `0x59d13834f7de5dcaeeadbd38d763dd16f38f4c9237a2bb04ecacc51f1a39ad6f`
- burn: `0x983eb977dfe3e3470285641197563c6437671f6088fa0c05eb60f21a781ee0e1`

## Milestone 3 Remaining

1. [ ] Run real browser UI smoke on Sepolia from merged `nodes.garden` `main`, including purchase prompt, demo mint-ready activation, mint, list, buy, burn, and sync confirmation.
2. [ ] Deploy Milestone 3 `NodeNFT` to Arbitrum mainnet.
3. [ ] Deploy Milestone 3 `NodeNFTMarketplace` to Arbitrum mainnet.
4. [ ] Configure production Rails mainnet env.
5. [ ] Enable controlled user cohort.
6. [ ] Track KPI counts for `>=300` mints, `>=100` trades, and `>=200` contract-interacting MAUs.
7. [ ] Coordinate public launch announcement with Arbitrum.

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
