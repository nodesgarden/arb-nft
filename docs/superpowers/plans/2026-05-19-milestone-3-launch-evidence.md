# Milestone 3 Launch And Evidence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package Milestone 3 for Arbitrum review with updated public docs, mainnet deployment evidence, KPI proof, and launch coordination assets.

**Architecture:** Keep public contract docs in `arb-nft` and app/runtime evidence tied to `nodes.garden`. Evidence must be link-driven, reproducible, and free of secrets. Submission text should be short; detailed proof lives in evidence files.

**Tech Stack:** Markdown docs, Foundry verification output, Rails analytics query, Arbiscan links, production screenshots.

---

## File Map

In `/Users/ilyalebedev/projects/arb-nft`:

- Modify: `README.md`
- Modify: `PLAN.md`
- Modify: `PROGRESS.md`
- Modify: `CONTRACT_SPEC.md`
- Modify: `API.md`
- Modify: `DEPLOYMENT.md`
- Create: `MILESTONE_3_EVIDENCE.md`
- Create: `MILESTONE_3_SUBMISSION.md`

In `/Users/ilyalebedev/projects/nodes.garden`:

- Use analytics dashboard/query output.
- Capture screenshots of purchase, mint, marketplace, burn/reveal, analytics.
- Do not commit secrets or private node keys.

## Task 1: Update Public Project Docs For Milestone 3

**Files:**
- Modify: `README.md`
- Modify: `PLAN.md`
- Modify: `PROGRESS.md`
- Modify: `CONTRACT_SPEC.md`
- Modify: `API.md`
- Modify: `DEPLOYMENT.md`

- [ ] **Step 1: Read current docs**

```sh
cd /Users/ilyalebedev/projects/arb-nft
sed -n '1,240p' README.md
sed -n '1,240p' PLAN.md
sed -n '1,240p' PROGRESS.md
sed -n '1,260p' CONTRACT_SPEC.md
sed -n '1,260p' API.md
sed -n '1,260p' DEPLOYMENT.md
```

- [ ] **Step 2: Update docs for mainnet scope**

Required wording:
- use `Arbitrum` for mainnet, not `Arbitrum Sepolia`
- keep Sepolia only in historical Milestone 1/2 sections
- describe signed user-paid mint
- describe burn-to-reveal
- describe public marketplace
- describe analytics and KPI proof path

- [ ] **Step 3: Check for stale claims**

Run:

```sh
rg -n "pending|still pending|testnet|Sepolia|hardcoded tester|BurnDisabled|Milestone 2 submission package is ready" README.md PLAN.md PROGRESS.md CONTRACT_SPEC.md API.md DEPLOYMENT.md
```

Expected: historical Sepolia mentions remain only where appropriate.

- [ ] **Step 4: Commit docs**

```sh
git add README.md PLAN.md PROGRESS.md CONTRACT_SPEC.md API.md DEPLOYMENT.md
git commit -m "Update docs for Milestone 3 mainnet launch"
```

## Task 2: Create Evidence Template

**Files:**
- Create: `MILESTONE_3_EVIDENCE.md`

- [ ] **Step 1: Create evidence sections**

Sections:
- Summary
- Mainnet contract deployment
- Contract verification
- Rails integration
- Mint KPI evidence
- Marketplace trade KPI evidence
- Wallet MAU evidence
- Screenshots
- Public launch announcement
- Security notes
- Test commands

- [ ] **Step 2: Add placeholders before deployment**

Use `TBD` only where evidence truly does not exist yet.

- [ ] **Step 3: Commit template**

```sh
git add MILESTONE_3_EVIDENCE.md
git commit -m "Add Milestone 3 evidence template"
```

## Task 3: Fill Mainnet Deployment Evidence

**Files:**
- Modify: `MILESTONE_3_EVIDENCE.md`
- Modify: `DEPLOYMENT.md`

- [ ] **Step 1: Record NodeNFT deployment**

Include:
- address
- deploy tx
- deployment block
- deployer
- admin
- operator
- mint authorizer
- verification URL

- [ ] **Step 2: Record marketplace deployment**

Include:
- address
- deploy tx
- deployment block
- constructor `NFT_CONTRACT`
- verification URL

- [ ] **Step 3: Record preflight tests**

Include exact outputs:
- `forge fmt --check`
- `forge build`
- `forge test --offline --no-auto-detect`

- [ ] **Step 4: Commit deployment evidence**

```sh
git add MILESTONE_3_EVIDENCE.md DEPLOYMENT.md
git commit -m "Record Milestone 3 mainnet deployment evidence"
```

## Task 4: Fill KPI Evidence

**Files:**
- Modify: `MILESTONE_3_EVIDENCE.md`

- [ ] **Step 1: Run analytics query in production**

Use Rails runner or dashboard output:

```sh
cd /Users/ilyalebedev/projects/nodes.garden
rbenv exec bundle exec rails runner 'pp NftMarketplace::AnalyticsQuery.new(network: "arbitrum_mainnet").call'
```

- [ ] **Step 2: Record KPI totals**

Must meet:
- `>=300` NFTs minted on Arbitrum
- `>=100` marketplace trades
- `>=200` wallet MAUs interacting with contracts

- [ ] **Step 3: Add sample tx links**

Include representative:
- mint txs
- listing txs
- purchase txs
- burn tx if used in demo

- [ ] **Step 4: Commit KPI evidence**

```sh
git add MILESTONE_3_EVIDENCE.md
git commit -m "Record Milestone 3 KPI evidence"
```

## Task 5: Capture UI Evidence

**Files:**
- Modify: `MILESTONE_3_EVIDENCE.md`
- Optional create under docs if screenshots are tracked publicly.

- [ ] **Step 1: Capture production screenshots**

Screens:
- purchase NFT/standard choice
- pending mint
- minted node detail
- marketplace listing grid
- listing detail
- burn-to-reveal warning
- revealed keys state with sensitive values redacted
- analytics dashboard

- [ ] **Step 2: Link screenshots**

Use public-safe images only. Redact wallets only if needed; do not expose private keys.

- [ ] **Step 3: Commit screenshot links/evidence**

```sh
git add MILESTONE_3_EVIDENCE.md
git commit -m "Add Milestone 3 UI evidence"
```

## Task 6: Create Submission Message

**Files:**
- Create: `MILESTONE_3_SUBMISSION.md`

- [ ] **Step 1: Draft short reviewer note**

Keep similar tone to accepted Milestone 1/2 notes:
- concise summary
- links only
- no overexplaining internals
- mention mainnet `Arbitrum`

- [ ] **Step 2: Include required links**

Links:
- repo
- Arbiscan NodeNFT
- Arbiscan marketplace
- evidence doc
- production marketplace/dashboard route if public
- public launch announcement

- [ ] **Step 3: Commit submission doc**

```sh
git add MILESTONE_3_SUBMISSION.md
git commit -m "Add Milestone 3 submission note"
```

## Acceptance Checks

- [ ] Public docs do not expose secrets.
- [ ] Mainnet deployment links are accurate.
- [ ] Evidence meets all three numeric KPIs.
- [ ] Screenshots prove real product flow, not just contract calls.
- [ ] Submission message is short and human-readable.
