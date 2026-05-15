# Milestone 2 Evidence

This file records public proof for Milestone 2 marketplace delivery.

Status: marketplace contract deployed and verified on Arbitrum Sepolia. Rails target env is configured, live sync works, production UI list/buy flow has been tested, and KPI event targets are met.

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

Production `nodes.garden` sync has indexed the KPI transactions and the final manual UI purchase test.

Verified on: `2026-05-16`

Indexed counts:

- total marketplace events: `1213`
- `ListingCreated`: `303`
- `ListingPurchased`: `101`
- `ListingCancelled`: `202`
- `NodeTransferSync`: `607`
- marketplace listings: `303`
- purchased listings: `101`
- cancelled listings: `202`
- active listings: `0`
- sync cursor block: `268740694`
- latest indexed event block: `268740385`

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
- final UI purchase test, Node #36/listing #303: `0xb952ee3c9167edb6d1f7a80127ba8c382dc1110035312cba137b37561de3ba7e`

Sample `ListingCancelled` tx hashes:

- `0x31c1df79897b63481020355bca184a9a5c2554b2b84e8ee60a722dfcf1ecc4d7`
- `0xd1cc1db33d69b0c23532e6b57f83521fa5fb0c149846f9203f01ff21bd72a908`
- `0x786480a3ba5089daee4b9f76bccc4fdff6522ef39d697f248ea99850b065b5f3`

## UI Evidence

- production URL: `https://nodes.garden/dashboard/marketplace`
- access: intentionally gated to whitelisted tester accounts for Milestone 2
- verified flow: seller listed Node #36 through the production UI; a different account purchased it through the production UI
- final purchase tx: `https://sepolia.arbiscan.io/tx/0xb952ee3c9167edb6d1f7a80127ba8c382dc1110035312cba137b37561de3ba7e`
- final indexed owner for token #36: `0xA3F00f3A194cDB68beA9082Ca55C10a06b72e314`
- on-chain active listing for token #36 after purchase: `0`

## Submission Package

- [x] marketplace contract address and verification URL recorded
- [x] deployment tx and block recorded
- [x] safe Rails env names recorded without secrets
- [x] KPI indexed counts recorded
- [x] sample create, purchase, and cancel tx hashes recorded
- [x] final production UI purchase tx recorded
- [x] gated production UI URL recorded
