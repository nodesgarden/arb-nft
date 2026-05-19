# Milestone 3 Dashboard UX Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add production-facing nodes.garden flows for choosing NFT mint at purchase, minting from wallet, trading mainnet NFTs, and burning to reveal keys.

**Architecture:** Use existing Rails dashboard and MetaMask transaction-prep pattern. UI prepares contract calls through Rails, user signs in wallet, and Rails updates state only after indexed events. Marketplace becomes public for valid listings but mint remains gated by eligible new exportable nodes.

**Tech Stack:** Rails views/controllers, Stimulus, ethers/browser wallet APIs, Tailwind-style existing CSS, RSpec request/system specs, `npm run build`.

---

## File Map

All files below are in `/Users/ilyalebedev/projects/nodes.garden`.

- Modify purchase/project views under `app/views/dashboard/projects/` or current purchase path.
- Modify node detail views under `app/views/dashboard/nodes/`.
- Modify marketplace view/controller under `app/views/dashboard/marketplace/` and `app/controllers/dashboard/marketplace_controller.rb`.
- Create/modify Stimulus controller for mint/burn transactions under `app/javascript/controllers/`.
- Add routes under `config/routes.rb`.
- Add request/system specs under `spec/requests/dashboard` and/or `spec/system`.

## Task 1: Add NFT Choice To New Node Purchase

**Files:**
- Modify current purchase form view/controller in dashboard project flow
- Test: request/system spec for purchase path

- [ ] **Step 1: Locate purchase UI**

Run:

```sh
cd /Users/ilyalebedev/projects/nodes.garden
rg -n "Buy|Purchase|purchase|project|tariff|Node" app/views app/controllers spec/requests
```

- [ ] **Step 2: Write failing specs**

Cover:
- eligible project shows NFT/standard choice
- ineligible project hides NFT choice
- standard choice submits existing purchase behavior
- NFT choice persists `ownership_mode=nft`

- [ ] **Step 3: Implement choice UI**

UI copy rules:
- write `Arbitrum`, not `Arbitrum Sepolia`
- NFT option: transferable, keys hidden until burn
- standard option: non-transferable, cannot later become NFT
- no milestone/testnet wording

- [ ] **Step 4: Run specs**

```sh
rbenv exec bundle exec rspec spec/requests/dashboard
npm run build
```

- [ ] **Step 5: Commit**

```sh
git add app/views app/controllers spec
git commit -m "Add Node NFT choice to purchase flow"
```

## Task 2: Add Mint Transaction Flow

**Files:**
- Add/modify controller: `app/controllers/dashboard/node_nfts_controller.rb`
- Add/modify Stimulus controller for wallet transaction
- Modify node detail view
- Test: request spec for transaction payload

- [ ] **Step 1: Write failing request specs**

Cover:
- pending NFT node returns mint transaction payload
- payload uses Arbitrum mainnet chain id `0xa4b1`
- payload includes typed authorization/signature
- already minted node does not return mint action
- wrong user cannot fetch mint payload

- [ ] **Step 2: Implement transaction endpoint**

Route suggestion:

```ruby
resource :node_nft, only: [] do
  get :mint_transaction
  get :status
end
```

Keep exact route consistent with existing dashboard style.

- [ ] **Step 3: Implement Stimulus wallet flow**

Flow:
- switch wallet to Arbitrum
- call `mintWithSignature`
- show pending state
- poll Rails status until indexed `NodeMinted`

- [ ] **Step 4: Run specs/build**

```sh
rbenv exec bundle exec rspec spec/requests/dashboard
npm run build
```

- [ ] **Step 5: Commit**

```sh
git add app/controllers app/javascript app/views config/routes.rb spec
git commit -m "Add wallet mint flow for Node NFTs"
```

## Task 3: Add Burn To Reveal Flow

**Files:**
- Modify: node detail controller/view
- Add/modify: wallet Stimulus controller
- Test: request spec for burn transaction/status

- [ ] **Step 1: Write failing specs**

Cover:
- NFT owner sees burn-to-reveal action
- listed NFT does not show burn action until listing cancelled
- non-owner cannot prepare burn transaction
- after indexed burn, keys ending `_key` or `_mnemonic` are visible
- renewal/prolong UI remains available after reveal

- [ ] **Step 2: Implement burn transaction endpoint**

Payload:
- chain id `0xa4b1`
- contract address = mainnet `NodeNFT`
- method `burn`
- args `[tokenId]`

- [ ] **Step 3: Implement warning UI**

Must state:
- burn is permanent
- NFT becomes non-transferable
- keys become visible
- node stays managed while subscription is active

- [ ] **Step 4: Implement revealed state UI**

After event-backed reveal:
- hide marketplace/NFT actions
- show revealed key fields
- show `keys revealed` status
- keep renewal/prolong controls

- [ ] **Step 5: Run specs/build**

```sh
rbenv exec bundle exec rspec spec/requests/dashboard spec/services/node_nfts
npm run build
```

- [ ] **Step 6: Commit**

```sh
git add app/controllers app/javascript app/views spec
git commit -m "Add burn to reveal dashboard flow"
```

## Task 4: Public Mainnet Marketplace UX

**Files:**
- Modify: `app/controllers/dashboard/marketplace_controller.rb`
- Modify: `app/views/dashboard/marketplace/show.html.erb`
- Modify: marketplace Stimulus controller
- Test: `spec/requests/dashboard/marketplace_spec.rb`

- [ ] **Step 1: Write failing marketplace specs**

Cover:
- public/allowed logged-in users can view mainnet listings
- only listed unrevealed NFTs appear
- create listing requires current wallet owns the NFT
- cancel requires seller wallet
- buy rejects own listing
- UI says `NODE #<id>`, not `TOKEN #<id>`

- [ ] **Step 2: Remove tester-only gate for public marketplace**

Do not enable minting for all existing nodes. Only marketplace viewing/trading becomes public.

- [ ] **Step 3: Update network/explorer labels**

Use config-driven:
- `Arbitrum`
- chain id `42161`
- mainnet Arbiscan URLs

- [ ] **Step 4: Preserve current marketplace improvements**

Keep:
- whole node card clickable
- project dropdown only for projects with active listings
- price filters
- untrimmed listing details

- [ ] **Step 5: Run specs/build**

```sh
rbenv exec bundle exec rspec spec/requests/dashboard/marketplace_spec.rb
npm run build
```

- [ ] **Step 6: Commit**

```sh
git add app/controllers/dashboard/marketplace_controller.rb app/views/dashboard/marketplace app/javascript spec/requests/dashboard/marketplace_spec.rb
git commit -m "Open mainnet Node NFT marketplace UX"
```

## Task 5: Browser Verification

**Files:**
- No code unless visual bugs found.

- [ ] **Step 1: Start dev server**

```sh
cd /Users/ilyalebedev/projects/nodes.garden
npm run build
bin/rails server
```

- [ ] **Step 2: Verify key screens**

Use browser:
- purchase page shows NFT/standard choice
- node detail pending mint state
- mint button does not overlap or overflow
- burn warning modal/page is readable on mobile and desktop
- marketplace listing cards are not clipped
- project and price filters work

- [ ] **Step 3: Fix visual bugs**

Run:

```sh
npm run build
rbenv exec bundle exec rspec spec/requests/dashboard
```

- [ ] **Step 4: Commit visual fixes**

```sh
git add app/views app/javascript app/assets spec
git commit -m "Polish Node NFT dashboard launch UI"
```

## Acceptance Checks

- [ ] New buyer can choose NFT or standard before node creation.
- [ ] NFT user can mint from wallet on Arbitrum.
- [ ] Marketplace can show and trade mainnet listings publicly.
- [ ] Burn reveal is clear, irreversible, and event-backed.
- [ ] UI avoids testnet/milestone wording.
