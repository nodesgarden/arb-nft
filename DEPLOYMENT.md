# Arbitrum Sepolia Deployment Runbook

This project deploys `NodeNFT` and `NodeNFTMarketplace` to Arbitrum Sepolia with Foundry.

Milestone 1 has already been deployed, verified, submitted to Arbitrum, and accepted. This runbook is retained for reproducibility and future testnet operations against the Milestone 1 contract.

Current handoff:

- `NodeNFT` is already deployed at the accepted address below.
- `NodeNFTMarketplace` is implemented locally but has not yet been deployed.
- Rails marketplace code is implemented in `/Users/ilyalebedev/projects/nodes.garden`.
- After marketplace deployment, Rails must be configured with the marketplace address and deployment block before the indexer can run.

Accepted Milestone 1 contract:

- network: `Arbitrum Sepolia`
- chain id: `421614`
- contract: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- explorer: `https://sepolia.arbiscan.io/address/0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392#code`

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
- `MINT_BATCH_FILE`
- `TRANSFER_BATCH_FILE`

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
export MINT_BATCH_FILE="script/examples/mint-batch.example.json"
export TRANSFER_BATCH_FILE="script/examples/transfer-batch.example.json"
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
   export NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS="0x..."
   export NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK="..."
   ```

2. Run the Rails migration if not already applied:

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
- screenshot references for gated marketplace UI

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

## Notes

- do not commit secrets or private keys
- keep the deployment command and evidence package aligned
- if local `forge test` crashes on macOS, use the offline command shown above; deployment and verification commands themselves must remain online
