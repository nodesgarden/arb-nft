# Implementation Plan — Node NFT Milestones

Current status:

- Milestone 1 is completed, submitted to Arbitrum, and accepted.
- Milestone 2 contract implementation is completed, deployed, and verified on Arbitrum Sepolia.
- Milestone 2 Rails marketplace backend/UI/indexer foundation is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 2 target Rails env configuration, live sync, and KPI on-chain proof are completed.
- Final screenshot/export evidence package is still pending.

## Milestone 2 Resume Plan — Testnet Node NFT Marketplace

Goal: deploy and prove the fixed-price Node NFT marketplace on Arbitrum Sepolia, with Rails indexing and gated tester UI.

Already implemented in this repo:

- `src/NodeNFTMarketplace.sol`
- `test/NodeNFTMarketplace.t.sol`
- `script/DeployNodeNFTMarketplace.s.sol`
- `script/CreateMarketplaceListingsBatch.s.sol`
- `script/BuyMarketplaceListingsBatch.s.sol`
- `script/CancelMarketplaceListingsBatch.s.sol`
- docs for contract behavior and deployment

Already implemented in `nodes.garden` `main`:

- marketplace tables and migration
- `NftMarketplace::Listing`, `NftMarketplace::Event`, `NftMarketplace::SyncCursor`
- `NodeNft.owner_address` and sync metadata
- event applier for create/cancel/purchase/transfer logs
- JSON-RPC log decoder and syncer
- `NftMarketplace::SyncJob` GoodJob cron hook
- gated `/dashboard/marketplace` UI
- MetaMask Stimulus controller for list/cancel/buy
- transaction prep/status endpoints
- hardcoded tester allowlist currently `[1]`

Deployment completed:

1. `NodeNFTMarketplace`: `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
2. deployment tx: `0x1ede554180b94ea92f117f38dab1bc26a7f7e702fe8303b2c5f281b4db2de16d`
3. deployment block: `268201592`
4. verification URL: `https://sepolia.arbiscan.io/address/0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A#code`

Required next steps:

1. Capture gated marketplace UI screenshots.
2. Export or screenshot Rails indexed counts.
3. Submit Milestone 2 evidence package.

Verification commands before resuming deployment:

```sh
# arb-nft
forge fmt --check
forge build
forge test --offline --no-auto-detect

# nodes.garden
cd /Users/ilyalebedev/projects/nodes.garden
rbenv exec bundle exec rspec
npm run build
```

Latest `arb-nft` verification before deployment resume:

- `forge fmt --check`: passed
- `forge build`: passed
- `forge test --offline --no-auto-detect`: `39 tests passed, 0 failed`

## Historical Plan — Milestone 1: Node NFT Smart Contract (Arbitrum Testnet)

Status: completed, submitted to Arbitrum, and accepted.

## Scope (Milestone 1 Only)
Deliver and deploy the Node NFT smart contract on Arbitrum testnet with metadata, ownership transfer, subscription extension, internal tests, and documentation.

## Milestone Targets
- Deliverables:
  - ERC-721 Node NFT contract deployed on Arbitrum Sepolia
  - Metadata API references for node type, status, and subscription expiry
  - Ownership transfer logic
  - Subscription extension function
  - Internal test suite + documentation
- Success criteria:
  - ≥100 Node NFTs minted on testnet
  - Transfers tested across multiple wallets
- Deadline: 10 Jan, 2026

## Assumptions / Inputs Needed
- Target testnet: Arbitrum Sepolia (confirmed)
- Wallets for deployment and test transfers
- Node metadata schema (node types, lifecycle states, expiry format)
- Subscription extension rules (pricing, duration increments, max limits)
- Minting flow is optional and triggered by nodes.garden after off-chain payment
- Private node data stays off-chain; NFT is a reference + access right
- Minter is a nodes.garden hot wallet (role-based access control)
- On-chain fields: nodeType, subscriptionExpiry, nodeId
- tokenURI uses baseURI + tokenId pointing to nodes.garden API
- Emit transfer sync event with nodeId
- Burn will be stubbed (disabled) for Milestone 1
- Hot wallet is the deploy-time operator (no multisig yet)
- extendSubscription sets a new expiry timestamp (`uint64`)
- nodeId is a uint256 (DB integer)

## Execution Plan
1. Repo & Architecture Review
   - Locate existing smart contract tooling (Foundry/Hardhat), config, and deployment scripts.
   - Decide contract structure, roles, and upgrade strategy (if any).
   - Stack choice: Foundry + OpenZeppelin (default unless changed)

2. Contract Specification
   - Define ERC-721 interface surface: mint, transfer, burn (if needed), extendSubscription, metadata getters.
   - Define metadata encoding: on-chain minimal fields + tokenURI to nodes.garden API.
   - Define lifecycle states and transition rules.
   - Define access control for minting and extension (nodes.garden operator role).
   - Define baseURI management (owner-only) for tokenURI resolution.
   - Define Transfer event with nodeId for backend sync.

3. Implement Contracts
   - Implement Node NFT contract (ERC-721) with metadata fields.
   - Implement subscription extension logic with validation (called by operator after off-chain payment).
   - Implement ownership transfer hooks if needed for off-chain sync.
   - Stub burn function behind role or disabled flag for Milestone 1.

4. Testing
   - Unit tests for minting, metadata correctness, transfers, and subscription extension.
   - Negative tests for invalid extensions and unauthorized actions.
   - Multi-wallet transfer tests to validate ownership flows.

5. Deployment (Testnet)
   - Prepare deploy script for Arbitrum testnet.
   - Deploy contract and verify on explorer.
   - Record contract address and deploy artifacts.

6. Documentation
   - Contract overview, functions, and examples.
   - Deployment instructions and test execution steps.
   - Metadata schema reference and tokenURI format.
   - Off-chain linkage notes (node data stored in nodes.garden DB).

## Definition of Done
- [x] Contract deployed and verified on Arbitrum Sepolia.
- [x] Tests passing locally/CI with coverage of core flows.
- [x] Documentation complete and reviewed.
- [x] 100+ testnet mints executed; multi-wallet transfers verified.
- [x] Milestone 1 submitted to Arbitrum and accepted.

## Out of Scope
- Marketplace backend/UI
- Mainnet deployment
- User onboarding or analytics dashboard
- Any Milestone 2–4 work
