# Milestone 2 Submission Package

This is the reviewer-facing summary for the nodes.garden Node NFT marketplace milestone.

## Product

nodes.garden lets users run crypto infrastructure nodes. The Node NFT represents a transferable subscription/access right for a node, while private node credentials and lifecycle data stay off-chain in nodes.garden.

Milestone 2 adds a fixed-price native ETH marketplace for active Node NFTs on Arbitrum Sepolia.

## Public Links

- Production app: `https://nodes.garden`
- Gated marketplace UI: `https://nodes.garden/dashboard/marketplace`
- Marketplace contract: `https://sepolia.arbiscan.io/address/0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
- Marketplace verified source: `https://sepolia.arbiscan.io/address/0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A#code`
- NodeNFT contract: `https://sepolia.arbiscan.io/address/0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- Marketplace deployment tx: `https://sepolia.arbiscan.io/tx/0x1ede554180b94ea92f117f38dab1bc26a7f7e702fe8303b2c5f281b4db2de16d`

## Contract Addresses

- network: `Arbitrum Sepolia`
- chain id: `421614`
- `NodeNFT`: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- `NodeNFTMarketplace`: `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`
- deployment block: `268201592`
- deployer: `0xA3F00f3A194cDB68beA9082Ca55C10a06b72e314`

## Marketplace Features Delivered

- Sellers can list active Node NFTs for a fixed native ETH price.
- Listed NFTs are escrowed by the marketplace contract.
- Sellers can cancel active listings and recover the NFT.
- Buyers can purchase active listings with exact ETH payment.
- Seller receives payment directly; no protocol fee is charged in Milestone 2.
- Rails indexes `ListingCreated`, `ListingCancelled`, `ListingPurchased`, and `NodeTransferSync` logs.
- Production dashboard shows listed Node NFTs, listing details, filters, and tester-gated list/cancel/buy controls.

## KPI Evidence

Verified in production Rails sync on `2026-05-16`:

- `ListingCreated`: `303`
- `ListingPurchased`: `101`
- `ListingCancelled`: `202`
- `NodeTransferSync`: `607`
- marketplace listings indexed: `303`
- purchased listings: `101`
- cancelled listings: `202`
- active listings after final test: `0`
- sync cursor block: `268740694`

Targets:

- `>=300` listing-created events: met
- `>=100` buy/sell events: met

## Sample Transactions

Listing created:

- `https://sepolia.arbiscan.io/tx/0x5525f26164ce7808cdae13bb66bb6ef71dbfd410169e58ef614084766a9f1ca6`
- `https://sepolia.arbiscan.io/tx/0x3457f5d542c775bde84f99aeb5d04ae7fcbe52b763ac3d618d7abb18223868a6`
- `https://sepolia.arbiscan.io/tx/0x3a9ca281167fb22f0c86bae1a96a18ab6d0b204633d51edf3d968057fad62276`

Listing purchased:

- `https://sepolia.arbiscan.io/tx/0xddda6a611dcede4ad9401142840d6759c6c80608570b44fef6f607dbeca1b694`
- `https://sepolia.arbiscan.io/tx/0x901f28f0b868be81418a15bcd91da1890ab40c7972f4d80fefe1bf60fea3c6cf`
- `https://sepolia.arbiscan.io/tx/0x6b7e2566f15571276d7f97a23d6b2694f2560ae6484ca482c8691de619f5deaf`
- final production UI purchase of Node #36/listing #303: `https://sepolia.arbiscan.io/tx/0xb952ee3c9167edb6d1f7a80127ba8c382dc1110035312cba137b37561de3ba7e`

Listing cancelled:

- `https://sepolia.arbiscan.io/tx/0x31c1df79897b63481020355bca184a9a5c2554b2b84e8ee60a722dfcf1ecc4d7`
- `https://sepolia.arbiscan.io/tx/0xd1cc1db33d69b0c23532e6b57f83521fa5fb0c149846f9203f01ff21bd72a908`
- `https://sepolia.arbiscan.io/tx/0x786480a3ba5089daee4b9f76bccc4fdff6522ef39d697f248ea99850b065b5f3`

## Final UI Flow Test

The production UI was tested with two accounts:

- seller listed Node #36
- buyer account purchased Node #36
- latest indexed event: `listing_purchased`
- listing id: `303`
- token id: `36`
- final owner: `0xA3F00f3A194cDB68beA9082Ca55C10a06b72e314`
- final purchase block: `268740385`
- active listing id for token #36 after purchase: `0`

## Supporting Files

- [MILESTONE_2_EVIDENCE.md](MILESTONE_2_EVIDENCE.md)
- [CONTRACT_SPEC.md](CONTRACT_SPEC.md)
- [DEPLOYMENT.md](DEPLOYMENT.md)
- [PROGRESS.md](PROGRESS.md)
- [README.md](README.md)
