# Milestone 3 Rails Mint And Reveal Domain Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add nodes.garden backend state for new-node NFT minting, one-time mint authorization, and event-backed burn-to-reveal.

**Architecture:** Keep smart contracts in `arb-nft`; implement Rails domain logic in `/Users/ilyalebedev/projects/nodes.garden`. Rails creates mint authorizations only after paid new-node purchase, indexes contract events as truth, and reveals private fields only after confirmed burn.

**Tech Stack:** Ruby on Rails, ActiveRecord, RSpec, ethers-compatible EIP-712 signing, JSON-RPC event indexing.

---

## File Map

All files below are in `/Users/ilyalebedev/projects/nodes.garden`.

- Modify: `app/models/node.rb` - expose hidden key fields only when reveal is confirmed.
- Modify: `app/models/node_nft.rb` - add lifecycle states for mint pending, minted, burned/revealed.
- Create: `app/models/node_nft_mint_authorization.rb` or equivalent - stores one-time mint authorization.
- Create migration: `db/migrate/*_add_mainnet_node_nft_lifecycle.rb`.
- Create service: `app/services/node_nfts/mint_authorization_issuer.rb`.
- Create service: `app/services/node_nfts/revealable_data.rb`.
- Modify purchase flow controller/service that creates nodes after payment.
- Add request specs/model specs under `spec/`.

## Task 1: Add Lifecycle Schema

**Files:**
- Modify/create migration in `db/migrate/`
- Modify: `app/models/node_nft.rb`
- Create: `app/models/node_nft_mint_authorization.rb` if using dedicated table
- Test: `spec/models/node_nft_spec.rb`
- Test: `spec/models/node_nft_mint_authorization_spec.rb`

- [ ] **Step 1: Write failing model specs**

Cover:
- `NodeNft` can represent `mint_pending`, `minted`, `keys_revealed`
- `keys_revealed` permanently disables marketplace eligibility
- mint authorization nonce is unique
- mint authorization expires
- mint authorization is bound to wallet address and node

- [ ] **Step 2: Run failing specs**

```sh
cd /Users/ilyalebedev/projects/nodes.garden
rbenv exec bundle exec rspec spec/models/node_nft_spec.rb spec/models/node_nft_mint_authorization_spec.rb
```

Expected: fail because schema/model does not exist.

- [ ] **Step 3: Add migration**

Minimum fields:
- `node_nfts.network` string, default mainnet/sepolia-safe value if not already present
- `node_nfts.mint_status` string or enum
- `node_nfts.keys_revealed_at` datetime
- `node_nfts.burned_at` datetime
- `node_nfts.burn_tx_hash` string
- `node_nfts.nft_locked` boolean default false
- mint authorization table with `node_id`, `wallet_address`, `nonce`, `deadline`, `signature`, `used_at`

Do not mix Sepolia and mainnet records.

- [ ] **Step 4: Add model validations/scopes**

Rules:
- wallet addresses normalized lowercase
- only new exportable nodes can receive mint authorization
- revealed/burned nodes cannot be listed

- [ ] **Step 5: Run specs and migration**

```sh
rbenv exec bundle exec rails db:migrate
rbenv exec bundle exec rspec spec/models/node_nft_spec.rb spec/models/node_nft_mint_authorization_spec.rb
```

Expected: pass.

- [ ] **Step 6: Commit**

```sh
git add app/models db/migrate spec/models
git commit -m "Add Node NFT lifecycle state"
```

## Task 2: Add Mint Authorization Issuer

**Files:**
- Create: `app/services/node_nfts/mint_authorization_issuer.rb`
- Modify: `app/services/nft_marketplace.rb` or create `app/services/node_nfts/config.rb`
- Test: `spec/services/node_nfts/mint_authorization_issuer_spec.rb`

- [ ] **Step 1: Write failing service specs**

Cover:
- rejects old/existing nodes with already exposed keys
- rejects nodes with non-exportable projects
- signs payload for paid new node only
- signature payload includes `to`, `nodeId`, `nodeType`, `subscriptionExpiry`, `nonce`, `deadline`
- signature is chain/contract specific
- repeated authorization reuses or invalidates cleanly, but does not create multiple usable nonces unintentionally

- [ ] **Step 2: Run failing spec**

```sh
rbenv exec bundle exec rspec spec/services/node_nfts/mint_authorization_issuer_spec.rb
```

- [ ] **Step 3: Implement issuer**

Service input:
- `node:`
- `wallet_address:`
- `user:`

Service output:
- typed data hash for frontend
- signature
- mint contract address
- chain id
- deadline
- nonce

Use env:
- `NODE_NFT_MAINNET_CONTRACT_ADDRESS`
- `NODE_NFT_MINT_AUTHORIZER_PRIVATE_KEY` or Rails credentials equivalent
- `ARB_MAINNET_CHAIN_ID=42161`

- [ ] **Step 4: Run service spec**

```sh
rbenv exec bundle exec rspec spec/services/node_nfts/mint_authorization_issuer_spec.rb
```

Expected: pass.

- [ ] **Step 5: Commit**

```sh
git add app/services/node_nfts spec/services/node_nfts
git commit -m "Issue signed Node NFT mint authorizations"
```

## Task 3: Wire New Node Purchase Choice

**Files:**
- Modify purchase/create-node controller/service in `nodes.garden`
- Modify payment success/finalization flow that creates `Node`
- Add request spec for purchase flow

- [ ] **Step 1: Locate purchase flow**

Run:

```sh
cd /Users/ilyalebedev/projects/nodes.garden
rg -n "Purchase|purchase|payment|Node.create|nodes.create|tariff" app spec
```

- [ ] **Step 2: Write failing request/service specs**

Cover:
- after successful payment user may choose NFT path
- NFT path creates node with private keys hidden
- standard path keeps current non-transferable behavior
- existing nodes cannot request mint authorization
- node must be exportable

- [ ] **Step 3: Add `ownership_mode` parameter**

Accepted values:
- `nft`
- `standard`

Persist enough state to prevent later conversion from standard to NFT.

- [ ] **Step 4: Return mint authorization**

After node creation and payment confirmation, return mint authorization payload for NFT path. Do not mark as minted yet.

- [ ] **Step 5: Run purchase specs**

```sh
rbenv exec bundle exec rspec spec/requests spec/services/node_nfts
```

- [ ] **Step 6: Commit**

```sh
git add app spec
git commit -m "Wire Node NFT mint option into purchase flow"
```

## Task 4: Implement Revealable Data Service

**Files:**
- Create: `app/services/node_nfts/revealable_data.rb`
- Modify: `app/models/node.rb`
- Test: `spec/services/node_nfts/revealable_data_spec.rb`
- Test: `spec/models/node_spec.rb`

- [ ] **Step 1: Write failing specs**

Cover:
- before reveal, `_key` and `_mnemonic` fields stay hidden
- after confirmed burn, all keys ending `_key` or `_mnemonic` are shown
- non-key internal fields remain hidden if already hidden by current `safe_data`
- empty/non-hash `data` returns safe empty output

- [ ] **Step 2: Implement service**

Rules:
- use suffix match `/(_key|_mnemonic)\z/`
- reveal only for nodes with confirmed `keys_revealed_at`
- do not mutate `node.data`

- [ ] **Step 3: Run specs**

```sh
rbenv exec bundle exec rspec spec/services/node_nfts/revealable_data_spec.rb spec/models/node_spec.rb
```

- [ ] **Step 4: Commit**

```sh
git add app/models/node.rb app/services/node_nfts spec
git commit -m "Reveal node keys after confirmed NFT burn"
```

## Acceptance Checks

- [ ] Existing nodes cannot be minted.
- [ ] Standard new nodes cannot later become NFTs.
- [ ] Mint authorization is one-time and mainnet contract-bound.
- [ ] Keys reveal only after indexed `NodeBurned`.
- [ ] Existing non-NFT node behavior stays intact.
