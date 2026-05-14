# Milestone 2 Evidence

This file records public proof for Milestone 2 marketplace delivery.

Status: marketplace contract deployed and verified on Arbitrum Sepolia. Rails target env is configured, live sync works, and KPI event targets are met.

## Deployment

- network: `Arbitrum Sepolia`
- chain id: `421614`
- NodeNFT contract: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- NodeNFTMarketplace contract: `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
- deployment tx hash: `0x1ede554180b94ea92f117f38dab1bc26a7f7e702fe8303b2c5f281b4db2de16d`
- deployment block: `268201592`
- deployer address: `0xA3F00f3A194cDB68beA9082Ca55C10a06b72e314`
- constructor `NFT_CONTRACT`: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- verification URL: `https://sepolia.arbiscan.io/address/0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A#code`
- broadcast artifact: `broadcast/DeployNodeNFTMarketplace.s.sol/421614/run-latest.json`

## Required Rails Env

Set these in the target `nodes.garden` environment:

```sh
ARB_SEPOLIA_RPC_URL=<your-arbitrum-sepolia-rpc-url>
NODE_NFT_CONTRACT_ADDRESS=0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392
NODE_NFT_MARKETPLACE_CONTRACT_ADDRESS=0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A
NODE_NFT_MARKETPLACE_DEPLOYMENT_BLOCK=268201592
```

## Rails Sync Evidence

Production `nodes.garden` sync was run manually after KPI transactions.

Indexed counts:

- total marketplace events: `1200`
- `ListingCreated`: `300`
- `ListingPurchased`: `100`
- `ListingCancelled`: `200`
- marketplace listings: `300`
- purchased listings: `100`
- cancelled listings: `200`
- active listings: `0`
- sync cursor block: `268304072`

KPI status:

- [x] `>=300` listing-created events
- [x] `>=100` buy/sell events

Sample `ListingCreated` tx hashes:

- `0x5525f26164ce7808cdae13bb66bb6ef71dbfd410169e58ef614084766a9f1ca6`
- `0x3457f5d542c775bde84f99aeb5d04ae7fcbe52b763ac3d618d7abb18223868a6`
- `0x3a9ca281167fb22f0c86bae1a96a18ab6d0b204633d51edf3d968057fad62276`

Sample `ListingPurchased` tx hashes:

- `0xddda6a611dcede4ad9401142840d6759c6c80608570b44fef6f607dbeca1b694`
- `0x901f28f0b868be81418a15bcd91da1890ab40c7972f4d80fefe1bf60fea3c6cf`
- `0x6b7e2566f15571276d7f97a23d6b2694f2560ae6484ca482c8691de619f5deaf`

Sample `ListingCancelled` tx hashes:

- `0x31c1df79897b63481020355bca184a9a5c2554b2b84e8ee60a722dfcf1ecc4d7`
- `0xd1cc1db33d69b0c23532e6b57f83521fa5fb0c149846f9203f01ff21bd72a908`
- `0x786480a3ba5089daee4b9f76bccc4fdff6522ef39d697f248ea99850b065b5f3`

## Remaining Evidence Package Work

- [ ] Capture gated marketplace UI screenshots.
- [ ] Export or screenshot Rails indexed counts for submission.
