# Milestone 3 Mainnet Indexing And Analytics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make nodes.garden indexing network-aware for Arbitrum Mainnet and add an event-backed analytics dashboard for mints, trades, and wallet MAUs.

**Architecture:** Extend the existing `NftMarketplace` syncer instead of creating a separate stack. Store network on events/listings/cursors so Sepolia evidence and mainnet launch data cannot mix. Compute analytics from indexed mainnet contract events, not frontend clicks.

**Tech Stack:** Ruby on Rails, ActiveRecord, GoodJob, JSON-RPC logs, RSpec, Arbitrum Mainnet.

---

## File Map

All files below are in `/Users/ilyalebedev/projects/nodes.garden`.

- Modify: `app/services/nft_marketplace.rb` - network config for Arbitrum Mainnet.
- Modify: `app/services/nft_marketplace/log_decoder.rb` - decode `NodeMinted`, `NodeBurned`.
- Modify: `app/services/nft_marketplace/event_applier.rb` - apply mint/burn events.
- Modify: `app/services/nft_marketplace/syncer.rb` - use network-scoped cursors and addresses.
- Modify models/migrations for `nft_marketplace_events`, `nft_marketplace_listings`, `nft_marketplace_sync_cursors` network fields if missing.
- Create: `app/queries/nft_marketplace/analytics_query.rb`.
- Create controller/view for internal analytics route.
- Add specs under `spec/services/nft_marketplace` and `spec/queries/nft_marketplace`.

## Task 1: Make Marketplace Config Network-Aware

**Files:**
- Modify: `app/services/nft_marketplace.rb`
- Test: `spec/services/nft_marketplace/config_spec.rb`

- [ ] **Step 1: Write failing config specs**

Cover:
- mainnet config returns chain id `42161`
- mainnet config uses `ARB_MAINNET_RPC_URL`
- mainnet config uses mainnet NodeNFT and marketplace addresses
- sepolia config remains available for old evidence/dev
- explorer URL is mainnet/sepolia specific

- [ ] **Step 2: Run failing spec**

```sh
cd /Users/ilyalebedev/projects/nodes.garden
rbenv exec bundle exec rspec spec/services/nft_marketplace/config_spec.rb
```

- [ ] **Step 3: Implement config**

Env:
- `NFT_MARKETPLACE_NETWORK=arbitrum_mainnet`
- `ARB_MAINNET_RPC_URL`
- `ARB_MAINNET_WALLET_RPC_URL`
- `NODE_NFT_MAINNET_CONTRACT_ADDRESS`
- `NODE_NFT_MAINNET_MARKETPLACE_CONTRACT_ADDRESS`
- `NODE_NFT_MAINNET_DEPLOYMENT_BLOCK`
- `NODE_NFT_MAINNET_MARKETPLACE_DEPLOYMENT_BLOCK`

Keep Sepolia env as fallback/dev only.

- [ ] **Step 4: Run config spec**

```sh
rbenv exec bundle exec rspec spec/services/nft_marketplace/config_spec.rb
```

- [ ] **Step 5: Commit**

```sh
git add app/services/nft_marketplace.rb spec/services/nft_marketplace/config_spec.rb
git commit -m "Make NFT marketplace config network aware"
```

## Task 2: Add Network Columns And Scopes

**Files:**
- Create migration under `db/migrate/`
- Modify: `app/models/nft_marketplace/event.rb`
- Modify: `app/models/nft_marketplace/listing.rb`
- Modify: `app/models/nft_marketplace/sync_cursor.rb`
- Test related model specs

- [ ] **Step 1: Write failing model specs**

Cover:
- events are unique by `network + tx_hash + log_index`
- listings are scoped by network
- sync cursors are scoped by `network + contract_address`

- [ ] **Step 2: Add migration**

Add `network` with backfill:
- old records default `arbitrum_sepolia`
- new mainnet records use `arbitrum_mainnet`

- [ ] **Step 3: Add indexes**

Indexes:
- `nft_marketplace_events(network, tx_hash, log_index)` unique
- `nft_marketplace_listings(network, listing_id)` unique or equivalent
- `nft_marketplace_sync_cursors(network, contract_address)` unique

- [ ] **Step 4: Run migration and specs**

```sh
rbenv exec bundle exec rails db:migrate
rbenv exec bundle exec rspec spec/models/nft_marketplace
```

- [ ] **Step 5: Commit**

```sh
git add db/migrate app/models/nft_marketplace spec/models/nft_marketplace
git commit -m "Scope NFT marketplace data by network"
```

## Task 3: Decode And Apply Mint/Burn Events

**Files:**
- Modify: `app/services/nft_marketplace/log_decoder.rb`
- Modify: `app/services/nft_marketplace/event_applier.rb`
- Test: `spec/services/nft_marketplace/log_decoder_spec.rb`
- Test: `spec/services/nft_marketplace/event_applier_spec.rb`

- [ ] **Step 1: Write failing decoder specs**

Events:
- `NodeMinted(uint256 indexed tokenId,uint256 indexed nodeId,address indexed to)`
- `NodeBurned(uint256 indexed tokenId,uint256 indexed nodeId,address indexed owner)`

- [ ] **Step 2: Write failing applier specs**

Cover:
- mint creates/updates `NodeNft` from `tokenId`, `nodeId`, owner wallet
- mint marks mint authorization used
- burn marks node NFT burned/revealed/locked
- burn does not reveal data directly; it sets lifecycle state consumed by domain service
- duplicate logs are idempotent

- [ ] **Step 3: Implement decoder and applier**

Do not infer truth from client callbacks. Event log is source of truth.

- [ ] **Step 4: Run specs**

```sh
rbenv exec bundle exec rspec spec/services/nft_marketplace/log_decoder_spec.rb spec/services/nft_marketplace/event_applier_spec.rb
```

- [ ] **Step 5: Commit**

```sh
git add app/services/nft_marketplace spec/services/nft_marketplace
git commit -m "Index Node NFT mint and burn events"
```

## Task 4: Mainnet Sync Job

**Files:**
- Modify: `app/services/nft_marketplace/syncer.rb`
- Modify: `app/jobs/nft_marketplace/sync_job.rb`
- Test: `spec/services/nft_marketplace/syncer_spec.rb`

- [ ] **Step 1: Write failing sync specs**

Cover:
- syncer polls NodeNFT and marketplace contracts
- start blocks differ per contract
- cursors advance per network and contract
- failed RPC response does not corrupt cursor

- [ ] **Step 2: Implement network/contract cursor loop**

Poll:
- NodeNFT events from `NODE_NFT_MAINNET_DEPLOYMENT_BLOCK`
- Marketplace events from `NODE_NFT_MAINNET_MARKETPLACE_DEPLOYMENT_BLOCK`

- [ ] **Step 3: Run sync specs**

```sh
rbenv exec bundle exec rspec spec/services/nft_marketplace/syncer_spec.rb
```

- [ ] **Step 4: Commit**

```sh
git add app/services/nft_marketplace app/jobs/nft_marketplace spec/services/nft_marketplace
git commit -m "Sync mainnet Node NFT marketplace events"
```

## Task 5: Analytics Query And Dashboard

**Files:**
- Create: `app/queries/nft_marketplace/analytics_query.rb`
- Create/modify controller: `app/controllers/dashboard/nft_analytics_controller.rb`
- Create view: `app/views/dashboard/nft_analytics/show.html.erb`
- Add route in `config/routes.rb`
- Test: `spec/queries/nft_marketplace/analytics_query_spec.rb`
- Test: request spec for route access

- [ ] **Step 1: Write failing analytics specs**

Metrics:
- minted NFT count from `NodeMinted`
- marketplace trade count from `ListingPurchased`
- wallet MAU: unique wallet addresses in last 30 days from mainnet contract events
- sample transaction links

- [ ] **Step 2: Implement query object**

Query must only count `network = "arbitrum_mainnet"` for Milestone 3.

- [ ] **Step 3: Add dashboard route/view**

Route can be admin/internal while launch is prepared. Public KPI evidence can be copied into `MILESTONE_3_EVIDENCE.md`.

- [ ] **Step 4: Run specs**

```sh
rbenv exec bundle exec rspec spec/queries/nft_marketplace/analytics_query_spec.rb spec/requests/dashboard/nft_analytics_spec.rb
```

- [ ] **Step 5: Commit**

```sh
git add app/queries app/controllers app/views config/routes.rb spec
git commit -m "Add Node NFT analytics dashboard"
```

## Acceptance Checks

- [ ] Mainnet and Sepolia data cannot mix.
- [ ] `NodeMinted`, `NodeBurned`, transfer, listing, cancel, and purchase events are indexed.
- [ ] Analytics count contract events, not button clicks.
- [ ] MAU counts unique wallets in last 30 days.
- [ ] Query can produce KPI numbers for evidence docs.
