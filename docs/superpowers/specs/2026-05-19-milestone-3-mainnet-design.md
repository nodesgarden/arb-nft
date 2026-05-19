# Milestone 3 Mainnet Design

## Goal

Deliver Milestone 3: Arbitrum Mainnet deployment and initial user onboarding for Node NFTs and the internal marketplace.

Milestone 3 must prove:

- `>=300` Node NFTs minted on Arbitrum Mainnet
- `>=100` marketplace trades on Arbitrum Mainnet
- `>=200` monthly active wallets interacting with the contracts
- public launch announcement coordinated with Arbitrum

## Current Baseline

Milestone 1 and 2 are complete.

- `NodeNFT` exists on Arbitrum Sepolia with operator-only minting and burn disabled.
- `NodeNFTMarketplace` exists on Arbitrum Sepolia as fixed-price native ETH escrow.
- `nodes.garden` has gated marketplace UI, transaction preparation, JSON-RPC indexing, and event-backed ownership transfer.
- Existing production nodes are not safe to mint as NFTs because many already expose private keys to users.

Milestone 3 is not a straight redeploy. Mainnet needs new mint and reveal semantics.

## Product Model

New node purchase offers two paths:

1. **Mint Node NFT**
   - User chooses transferable NFT ownership.
   - Private keys stay hidden.
   - User can trade the NFT/node through marketplace while keys remain hidden.
   - User can later burn NFT to reveal private keys.

2. **Keep Standard Node**
   - User keeps current non-transferable node behavior.
   - Private keys may be visible through current app flow.
   - Node cannot be minted later as an NFT.

Existing nodes are excluded from minting unless explicitly migrated by future work. This avoids creating transferable assets for nodes whose keys may already be exposed.

## Burn To Reveal Model

Burn reveal does not stop nodes.garden management.

When user burns NFT:

- NFT is destroyed.
- Rails indexes burn event.
- Node becomes permanently non-transferable.
- Rails reveals all `node.data` fields whose keys end with `_key` or `_mnemonic`.
- Node remains managed by nodes.garden while subscription is active.
- Normal renewal/prolong flow stays available.
- Marketplace/NFT actions stay hidden forever for that node.

State name should avoid `exported`; use names like `keys_revealed`, `nft_locked`, or `revealed_at`.

## Mainnet Contract Design

Deploy a new mainnet `NodeNFT` version instead of reusing Sepolia semantics unchanged.

### Signed User-Paid Mint

Users pay gas for minting. Rails authorizes mint only after purchase and node creation.

Mint function should verify an operator/backend signature that binds:

- `to`
- `nodeId`
- `nodeType`
- `subscriptionExpiry`
- `nonce`
- `deadline`
- `chainId`
- verifying contract address

Do not include Rails user id on-chain. Rails maps wallet to user internally.

Preferred implementation: EIP-712 typed data.

Rules:

- signer must have `OPERATOR_ROLE` or dedicated `MINT_AUTHORIZER_ROLE`
- `to` must be non-zero
- `nodeId` must be non-zero and unused
- `nodeType` must be non-zero
- `subscriptionExpiry` must be in future
- nonce must be unused
- deadline must not be expired

Effects:

- mint NFT to `to`
- store node data
- map `nodeId -> tokenId`
- mark nonce used
- emit `NodeMinted`

### Burn

Owner can burn their token.

Rules:

- caller must own token or be approved operator
- token must exist
- active marketplace listing must be impossible because listed NFTs sit in marketplace escrow; marketplace contract, not user, owns listed token

Effects:

- capture `nodeId`
- delete token/node mappings
- burn ERC-721 token
- emit `NodeBurned(tokenId, nodeId, owner)`

Do not allow reminting burned/revealed `nodeId`.

### Marketplace

Deploy fixed-price marketplace to Arbitrum Mainnet for mainnet `NodeNFT`.

Milestone 3 can reuse Milestone 2 marketplace semantics:

- list active NFT
- escrow NFT
- cancel listing
- buy listing with exact native ETH
- seller receives payment directly
- no protocol fee unless explicitly added later

## Rails Domain Design

### Node NFT Eligibility

Mint allowed only for newly purchased exportable nodes.

Rails should track at least:

- whether node chose NFT path
- whether mint authorization exists
- whether NFT mint is confirmed
- whether keys were revealed
- whether NFT actions are permanently disabled

This can live in `node_nfts` plus new node-level fields or a new dedicated NFT lifecycle table. Exact schema belongs in implementation plan.

### Mint Authorization

After payment and node creation:

- Rails creates node with private keys in `nodes.data`
- Rails verifies node is exportable
- Rails creates one-time mint authorization for user's wallet
- Rails returns typed-data signature payload to frontend
- frontend sends `mintWithSignature` transaction
- indexer confirms `NodeMinted`
- Rails creates/updates `NodeNft`

Rails must not optimistically mark NFT minted before event confirmation.

### Reveal

Burn reveal flow:

- UI shows permanent warning
- frontend sends burn transaction
- Rails waits for `NodeBurned`
- event applier marks node as keys revealed and NFT locked
- UI reveals `_key` and `_mnemonic` fields from `node.data`

Reveal should be event-backed, not client-claim-backed.

### Existing Marketplace Indexer

Indexer becomes network-aware for Arbitrum Mainnet.

It must support:

- `NodeMinted`
- `NodeTransferSync`
- `NodeBurned`
- `ListingCreated`
- `ListingCancelled`
- `ListingPurchased`

Sepolia and mainnet state must not mix. Sync cursors, listings, events, and contract addresses need network separation.

## Dashboard UX

New purchase flow:

- user selects project/tier
- user chooses NFT transferable node or standard node
- NFT option explains keys hidden until burn
- standard option explains node cannot become transferable NFT later

Node detail UI:

- pending mint state
- mint transaction button
- NFT ownership/status
- marketplace actions if NFT exists and keys are not revealed
- burn-to-reveal button if NFT owner
- revealed keys section after confirmed burn
- renewal/prolong controls remain available after reveal

Marketplace:

- public launch path replaces tester-only gate
- only valid mainnet listings shown to public
- listed NFTs with unrevealed keys remain tradable
- revealed/burned nodes never listed

## Analytics

Analytics must use indexed mainnet contract events, not UI clicks.

Metrics:

- minted NFT count
- marketplace trade count
- unique contract-interacting wallets in last 30 days
- repeat traders
- sample tx links

Wallet MAU should count unique wallets from mainnet events:

- mint recipients/callers
- transfer senders/receivers
- listing sellers
- buyers
- burners

Dashboard should make Milestone 3 submission easy.

## Launch And Evidence

Launch mode:

- public launch allowed
- mint remains gated by new-node exportability/project eligibility
- no minting for existing exposed-key nodes

Evidence package should be built continuously:

- mainnet contract addresses
- deploy txs and verification links
- mint/trade/MAU counts
- sample txs
- screenshots
- announcement link
- security review notes

## Documentation Updates

Update public repo docs as part of Milestone 3:

- `README.md`
- `PLAN.md`
- `PROGRESS.md`
- `CONTRACT_SPEC.md`
- `API.md`
- `DEPLOYMENT.md`

Later create:

- `MILESTONE_3_EVIDENCE.md`
- `MILESTONE_3_SUBMISSION.md`

## Implementation Plan Split

Create separate implementation plans:

1. Mainnet contracts
2. Rails mint/reveal domain
3. Mainnet indexing and analytics
4. Dashboard UX
5. Launch/evidence docs

Each plan should be independently testable and shippable.

## Open Risks

- Private keys in `nodes.data` are not encrypted at rest by this design. This matches current state but should be revisited before broad production exposure.
- Burn reveal is irreversible. UI must make this clear.
- Mainnet deployment should use stronger operational controls than testnet hot-wallet-only deployment.
- Marketplace public launch needs abuse/spam controls if mint becomes available to broad users.
