# Arbitrum Sepolia Deployment Runbook

This project deploys `NodeNFT` and `NodeNFTMarketplace` to Arbitrum Sepolia with Foundry.

Milestone 1 has already been deployed, verified, submitted to Arbitrum, and accepted. This runbook is retained for reproducibility and future testnet operations against the Milestone 1 contract.

Current handoff:

- `NodeNFT` is already deployed at the accepted address below.
- `NodeNFTMarketplace` is deployed and verified at the accepted marketplace address below.
- Rails marketplace code is merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- After marketplace deployment, the target Rails env must be configured with the marketplace address and deployment block before the indexer can run.

Accepted Milestone 1 contract:

- network: `Arbitrum Sepolia`
- chain id: `421614`
- contract: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- explorer: `https://sepolia.arbiscan.io/address/0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392#code`

Milestone 2 marketplace contract:

- network: `Arbitrum Sepolia`
- chain id: `421614`
- contract: `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
- deployment tx hash: `0x1ede554180b94ea92f117f38dab1bc26a7f7e702fe8303b2c5f281b4db2de16d`
- deployment block: `268201592`
- constructor `NFT_CONTRACT`: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- explorer: `https://sepolia.arbiscan.io/address/0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A#code`

## Required Environment Variables

Contract constructor inputs:

- `ADMIN_ADDRESS`
- `OPERATOR_ADDRESS`
- `NFT_NAME`
- `NFT_SYMBOL`
- `BASE_URI`

Deployment and verification inputs:

- `ARB_SEPOLIA_RPC_URL`
- `DEPLOYER_PRIVATE_KEY`
- `ETHERSCAN_API_KEY`

Post-deploy operation inputs:

- `NFT_CONTRACT`
- `MARKETPLACE_CONTRACT`
- `OPERATOR_PRIVATE_KEY`
- `OWNER_PRIVATE_KEY`
- `BUYER_PRIVATE_KEY`
- `SELLER_PRIVATE_KEY`
- `MINT_BATCH_FILE`
- `TRANSFER_BATCH_FILE`
- `MARKETPLACE_LISTING_BATCH_FILE`
- `MARKETPLACE_BUY_BATCH_FILE`
- `MARKETPLACE_CANCELLATION_BATCH_FILE`

Rails marketplace inputs in `nodes.garden`:

- `ARB_SEPOLIA_RPC_URL`
- `NODE_NFT_CONTRACT_ADDRESS`
- `NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS`
- `NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK`
- optional `NFT_MARKETPLACE_SYNC_CRON`

## Suggested Local Export

```sh
export ARB_SEPOLIA_RPC_URL="https://your-arbitrum-sepolia-rpc"
export DEPLOYER_PRIVATE_KEY="0x..."
export ETHERSCAN_API_KEY="..."

export ADMIN_ADDRESS="0x..."
export OPERATOR_ADDRESS="0x..."
export NFT_NAME="nodes.garden Node NFT"
export NFT_SYMBOL="NODE"
export BASE_URI="https://nodes.garden/api/nft/"

export NFT_CONTRACT="0x..."
export MARKETPLACE_CONTRACT="0x..."
export OPERATOR_PRIVATE_KEY="0x..."
export OWNER_PRIVATE_KEY="0x..."
export BUYER_PRIVATE_KEY="0x..."
export SELLER_PRIVATE_KEY="0x..."
export MINT_BATCH_FILE="script/examples/mint-batch.example.json"
export TRANSFER_BATCH_FILE="script/examples/transfer-batch.example.json"
export MARKETPLACE_LISTING_BATCH_FILE="script/examples/marketplace-listings.example.json"
export MARKETPLACE_BUY_BATCH_FILE="script/examples/marketplace-buys.example.json"
export MARKETPLACE_CANCELLATION_BATCH_FILE="script/examples/marketplace-cancellations.example.json"
```

## Network Details

- network: Arbitrum Sepolia
- chain id: `421614`
- explorer: `https://sepolia.arbiscan.io`

## Pre-Deploy Verification

Run before broadcasting:

```sh
forge fmt --check
forge build
forge test --offline --no-auto-detect
```

## Deploy And Verify In One Pass

Preferred command:

```sh
forge script script/DeployNodeNFT.s.sol:DeployNodeNFT \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --broadcast \
  --verify \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  -vvv
```

Expected outputs:

- deployment transaction hash
- deployed contract address
- broadcast artifact under `broadcast/`
- verification submission status

## Deploy Marketplace

Deploy the marketplace after `NodeNFT` exists. The script reads `NFT_CONTRACT` and stores that address immutably.

```sh
forge script script/DeployNodeNFTMarketplace.s.sol:DeployNodeNFTMarketplace \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --broadcast \
  --verify \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  -vvv
```

Record the deployed marketplace address, deployment tx hash, deployer address, and start block for the Rails marketplace indexer.

After deployment:

1. Export or set Rails secrets/env in `nodes.garden`:

   ```sh
   export ARB_SEPOLIA_RPC_URL="https://your-arbitrum-sepolia-rpc"
   export NODE_NFT_CONTRACT_ADDRESS="0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392"
   export NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS="0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A"
   export NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK="268201592"
   ```

2. Apply the marketplace Rails migration in the target env if not already applied:

   ```sh
   cd /Users/ilyalebedev/projects/nodes.garden
   rbenv exec bundle exec rails db:migrate
   ```

3. Verify the Rails marketplace stack:

   ```sh
   rbenv exec bundle exec rspec spec/models/node_nft_spec.rb spec/services/nft_marketplace/event_applier_spec.rb spec/services/nft_marketplace/syncer_spec.rb spec/requests/dashboard/marketplace_spec.rb
   npm run build
   ```

4. Run one sync manually before relying on cron:

   ```sh
   rbenv exec bundle exec rails runner 'NftMarketplace::SyncJob.perform_now'
   ```

   If relying on scheduled sync instead, enable `GOOD_JOB_ENABLE_CRON=true` and keep `NFT_MARKETPLACE_SYNC_CRON` unset for the default one-minute cadence or set it explicitly.

## Standalone Verification Command

If verification needs to be retried manually:

```sh
forge verify-contract \
  --chain 421614 \
  --watch \
  --guess-constructor-args \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  <DEPLOYED_ADDRESS> \
  src/NodeNFT.sol:NodeNFT
```

Marketplace verification:

```sh
forge verify-contract \
  --chain 421614 \
  --watch \
  --guess-constructor-args \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  <DEPLOYED_MARKETPLACE_ADDRESS> \
  src/NodeNFTMarketplace.sol:NodeNFTMarketplace
```

## Post-Deploy Checklist

Record Milestone 1 evidence in `MILESTONE_1_EVIDENCE.md`. Record Milestone 2 marketplace evidence in a new Milestone 2 evidence section or file.

For `NodeNFT`:

- deployed address
- deployment tx hash
- verification URL
- deployer address
- admin address
- operator address
- base URI used at deployment

For `NodeNFTMarketplace`:

- deployed address
- deployment tx hash
- verification URL
- deployer address
- constructor `NFT_CONTRACT`
- deployment block used by Rails
- Rails env names and values shape, without secrets
- sample `ListingCreated`, `ListingCancelled`, and `ListingPurchased` tx hashes
- indexed Rails counts
- gated marketplace UI URL and final UI flow tx reference

## Batch Mint Workflow

Use the operator wallet for minting. The batch file contains aligned arrays for:

- `recipients`
- `nodeIds`
- `nodeTypes`
- `subscriptionExpiries`

Run:

```sh
forge script script/MintNodeNFTBatch.s.sol:MintNodeNFTBatch \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --broadcast \
  -vvv
```

The script reads:

- `NFT_CONTRACT`
- `OPERATOR_PRIVATE_KEY`
- `MINT_BATCH_FILE`

## Batch Transfer Workflow

Use the current token owner wallet for each transfer batch. The batch file contains aligned arrays for:

- `recipients`
- `tokenIds`

Run:

```sh
forge script script/TransferNodeNFTBatch.s.sol:TransferNodeNFTBatch \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --broadcast \
  -vvv
```

The script reads:

- `NFT_CONTRACT`
- `OWNER_PRIVATE_KEY`
- `TRANSFER_BATCH_FILE`

For multi-wallet milestone proof, run the transfer script once per source wallet.

## Marketplace KPI Batch Workflows

Create listings as the NFT owner. The script approves the marketplace for each token, then calls `createListing(tokenId, priceWei)`.

```sh
forge script script/CreateMarketplaceListingsBatch.s.sol:CreateMarketplaceListingsBatch \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --broadcast \
  -vvv
```

The listing script reads:

- `NFT_CONTRACT`
- `MARKETPLACE_CONTRACT`
- `OWNER_PRIVATE_KEY`
- `MARKETPLACE_LISTING_BATCH_FILE`

Buy listings as a buyer wallet:

```sh
forge script script/BuyMarketplaceListingsBatch.s.sol:BuyMarketplaceListingsBatch \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --broadcast \
  -vvv
```

The buy script reads:

- `MARKETPLACE_CONTRACT`
- `BUYER_PRIVATE_KEY`
- `MARKETPLACE_BUY_BATCH_FILE`

Cancel active listings as the seller wallet:

```sh
forge script script/CancelMarketplaceListingsBatch.s.sol:CancelMarketplaceListingsBatch \
  --rpc-url "$ARB_SEPOLIA_RPC_URL" \
  --broadcast \
  -vvv
```

The cancellation script reads:

- `MARKETPLACE_CONTRACT`
- `SELLER_PRIVATE_KEY`
- `MARKETPLACE_CANCELLATION_BATCH_FILE`

For KPI proof, generate listing and buy batches from the actual listing ids emitted on-chain. Do not guess listing ids when multiple wallets or retries are involved.

## Notes

- do not commit secrets or private keys
- keep the deployment command and evidence package aligned
- if local `forge test` crashes on macOS, use the offline command shown above; deployment and verification commands themselves must remain online
