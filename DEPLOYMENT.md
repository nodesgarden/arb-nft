# Arbitrum Sepolia Deployment Runbook

This project deploys `NodeNFT` to Arbitrum Sepolia with Foundry.

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
- `OPERATOR_PRIVATE_KEY`
- `OWNER_PRIVATE_KEY`
- `MINT_BATCH_FILE`
- `TRANSFER_BATCH_FILE`

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

## Post-Deploy Checklist

Record all of the following in `MILESTONE_1_EVIDENCE.md`:

- deployed address
- deployment tx hash
- verification URL
- deployer address
- admin address
- operator address
- base URI used at deployment

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
