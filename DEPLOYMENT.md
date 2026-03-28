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

## Notes

- do not commit secrets or private keys
- keep the deployment command and evidence package aligned
- if local `forge test` crashes on macOS, use the offline command shown above; deployment and verification commands themselves must remain online
