# Implementation Plan — Node NFT Milestones

Current status:

- Milestone 1 is completed, submitted to Arbitrum, and accepted.
- Milestone 2 contract implementation is completed, deployed, and verified on Arbitrum Sepolia.
- Milestone 2 Rails marketplace backend/UI/indexer foundation is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 2 target Rails env configuration, live sync, and KPI on-chain proof are completed.
- Milestone 2 submission package is ready.
- Milestone 3 contract changes are merged into `main`.
- Milestone 3 Rails integration is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PRs #265-#270.
- New Milestone 3 Sepolia contracts are deployed and verified for end-to-end testing before mainnet deployment.

## Milestone 3 Plan — Mainnet Deployment & Initial User Onboarding

Goal: deploy the Node NFT + marketplace stack to Arbitrum mainnet after a fresh Arbitrum Sepolia rehearsal, then integrate mint and burn flows into the nodes.garden user journey.

Success criteria from the grant:

- Deploy `NodeNFT` and `NodeNFTMarketplace` to Arbitrum mainnet.
- Integrate nodes.garden user flow: `Mint Node NFT` and `Burn to Reveal Key`.
- Onboard initial active user cohort.
- Provide basic analytics for NFT mints, trades, and MAUs.
- Reach at least `300` mainnet mints, `100` marketplace trades, and `200` contract-interacting MAUs.
- Coordinate public launch announcement with Arbitrum.

Implemented in `arb-nft`:

- `NodeNFT` now supports signed user-paid minting through `mintWithSignature`.
- `MINT_AUTHORIZER_ROLE` signs EIP-712 `MintAuthorization` payloads.
- `OPERATOR_ROLE` can still perform backend/operator minting.
- Burn is enabled for token owners and approved operators.
- `NodeBurned(tokenId, nodeId, owner)` is emitted for Rails reveal indexing.
- A burned `nodeId` cannot be re-minted.
- Mainnet deployment scripts are prepared.
- Arbitrum Sepolia smoke script covers mint, marketplace list, cancel, and burn.

Implemented in `nodes.garden` `main`:

- network-aware Sepolia/mainnet marketplace configuration
- network-scoped listings, events, cursors, and node NFT records
- `node_nfts` lifecycle states: `mint_pending`, `minted`, `keys_revealed`
- mint authorization persistence and EIP-712 signature generation
- `NodeMinted`, `NodeBurned`, and transfer event indexing
- node data masking before burn reveal, including pending mint state
- dashboard `Mint Node NFT` and `Burn to Reveal Key` actions
- chunked RPC log sync to avoid provider log-range limits
- project-level mintability gating for new node purchases
- new mintable nodes start with private data hidden; old/relaunched nodes keep legacy key behavior
- purchase redirect opens the node page with the NFT mint prompt for hidden nodes
- hidden nodes that are not yet mint-ready still show the NFT card and explain the pending state
- in-app "NFT is ready to mint" notification after a hidden node becomes active/exportable
- tester-only demo activation service for making waiting demo nodes mint-ready without real deployment work

Current Sepolia rehearsal deployment:

1. `NodeNFT`: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
2. `NodeNFT` deployment tx: `0xeebe17b06d6f83727a4e9b5c657d935b09c8aed73dbd19f6faec480486db8626`
3. `NodeNFT` deployment block: `269610905`
4. `NodeNFT` explorer: `https://sepolia.arbiscan.io/address/0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F#code`
5. `NodeNFTMarketplace`: `0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`
6. `NodeNFTMarketplace` deployment tx: `0x6fb15f13c6b0d371b9e9b8f31bf5e3d345c2ee8d63cf3dfc8bd617eddea58920`
7. `NodeNFTMarketplace` deployment block: `269611269`
8. `NodeNFTMarketplace` explorer: `https://sepolia.arbiscan.io/address/0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0#code`

Sepolia smoke evidence:

- mint tx: `0x72171f19be419535a1e7e3e92b88e8df4f5978a7c380cc9b13fe2dc5b6cdfb89`
- approve tx: `0x021c7981d5b99bf3c20dcb9444b928bce1bb207de6f197161e1bd23b3b95a472`
- list tx: `0x622c14da0eb30065f465562ea0bb29116e962221a06710466a97b5dcf3ef2d8f`
- cancel tx: `0x59d13834f7de5dcaeeadbd38d763dd16f38f4c9237a2bb04ecacc51f1a39ad6f`
- burn tx: `0x983eb977dfe3e3470285641197563c6437671f6088fa0c05eb60f21a781ee0e1`

Remaining before mainnet:

1. Run a real browser UI smoke against the new Sepolia contracts and merged Rails `main`:
   - purchase or prepare an exportable node
   - confirm hidden private data and the NFT prompt on the node page
   - for demo/test nodes, trigger the in-app mint-ready activation path if the node is still waiting
   - mint Node NFT from the node page
   - sync and confirm `NodeMinted`
   - list on marketplace
   - buy from another wallet
   - sync and confirm Rails node ownership transfer
   - burn to reveal keys
   - sync and confirm `keys_revealed`
2. Deploy `NodeNFT` and `NodeNFTMarketplace` to Arbitrum mainnet.
3. Configure production Rails mainnet env.
4. Launch controlled cohort.
5. Track mainnet KPI progress.

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

Submission package:

1. Reviewer-facing summary: [MILESTONE_2_SUBMISSION.md](MILESTONE_2_SUBMISSION.md)
2. Detailed evidence: [MILESTONE_2_EVIDENCE.md](MILESTONE_2_EVIDENCE.md)
3. Production gated marketplace URL: `https://nodes.garden/dashboard/marketplace`

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
