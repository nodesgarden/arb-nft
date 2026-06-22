# Milestone 3 Evidence — Sepolia Rehearsal

Status: Milestone 3 contracts and Rails integration are implemented, deployed to Arbitrum Sepolia, smoke-tested through the real nodes.garden browser flow, deployed to Arbitrum mainnet, and enabled in production Rails mainnet config.

Milestone 3 scope:

- signed user-paid `Mint Node NFT`
- `Burn to Reveal Key`
- marketplace list and buy flow
- Rails event indexing for mints, transfers, listings, purchases, and burns
- hidden private node data until explicit reveal
- demo activation path for test nodes that are not actually deployed with real key material

## Contracts

`NodeNFT`:

- network: `Arbitrum Sepolia`
- chain id: `421614`
- address: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
- deployment tx: `0xeebe17b06d6f83727a4e9b5c657d935b09c8aed73dbd19f6faec480486db8626`
- deployment block: `269610905`
- explorer: `https://sepolia.arbiscan.io/address/0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F#code`

`NodeNFTMarketplace`:

- network: `Arbitrum Sepolia`
- chain id: `421614`
- address: `0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0`
- deployment tx: `0x6fb15f13c6b0d371b9e9b8f31bf5e3d345c2ee8d63cf3dfc8bd617eddea58920`
- deployment block: `269611269`
- constructor `NFT_CONTRACT`: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`
- explorer: `https://sepolia.arbiscan.io/address/0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0#code`

## Scripted Contract Smoke

The Foundry smoke script minted with signature, approved/listed/cancelled on the marketplace, then burned the token:

- mint: `0x72171f19be419535a1e7e3e92b88e8df4f5978a7c380cc9b13fe2dc5b6cdfb89`
- approve marketplace: `0x021c7981d5b99bf3c20dcb9444b928bce1bb207de6f197161e1bd23b3b95a472`
- list: `0x622c14da0eb30065f465562ea0bb29116e962221a06710466a97b5dcf3ef2d8f`
- cancel listing: `0x59d13834f7de5dcaeeadbd38d763dd16f38f4c9237a2bb04ecacc51f1a39ad6f`
- burn: `0x983eb977dfe3e3470285641197563c6437671f6088fa0c05eb60f21a781ee0e1`

## Browser UI Smoke

Production-gated Sepolia UI flow completed on `nodes.garden`.

Test node:

- Rails node id: `25822`
- project: `Dria`
- NFT token id: `4`
- final Rails node owner user id: `256`
- final owner wallet: `0xa3f00f3a194cDB68beA9082Ca55C10a06b72e314`
- final NFT status: `keys_revealed`
- contract: `0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F`

Completed browser flow:

1. Purchased a fresh Dria node.
2. Used tester-only demo activation to make the queued test node mint-ready.
3. Minted Node NFT from the node page.
4. Listed the NFT from the marketplace UI.
5. Purchased the listing from another user/wallet.
6. Verified Rails node ownership moved to the buyer.
7. Burned the NFT from the buyer account.
8. Verified Rails indexed `NodeBurned` and revealed keys.

Browser flow transactions:

- mint NFT #4: `0x1fa3e5c8f64fa75cf749d54ec3dd81e44fca2b78e1a5b5af6c8b7d7710a93019`
- listing #2 created: `0xa0849d8e4888cf134d5460a190e32f72c1757c843b1f5faaa77dfb5641c973c6`
- listing #2 purchased: `0x2ec3f1f3c820ce8db917cc266eba27f35de6ddcdb69332476e05e0046d32b06c`
- burn/reveal: `0x4cf1587f18cad071b5e8b9225cba82787269a4ecac53d8b04de20cf2569bfb44`

Marketplace listing row:

- Rails listing id: `305`
- contract listing id: `2`
- token id: `4`
- status: `purchased`
- seller: `0x03a6948018941a8650c08145abba2f25cc79e32c`
- buyer: `0xa3f00f3a194cdb68bea9082ca55c10a06b72e314`
- price: `0.001 ETH`

Indexed events for NFT #4:

- `NodeMinted`: block `279643494`, tx `0x1fa3e5c8f64fa75cf749d54ec3dd81e44fca2b78e1a5b5af6c8b7d7710a93019`
- `NodeTransferSync` to marketplace escrow: block `279651096`, tx `0xa0849d8e4888cf134d5460a190e32f72c1757c843b1f5faaa77dfb5641c973c6`
- `ListingCreated`: block `279651096`, tx `0xa0849d8e4888cf134d5460a190e32f72c1757c843b1f5faaa77dfb5641c973c6`
- `NodeTransferSync` to buyer: block `279651328`, tx `0x2ec3f1f3c820ce8db917cc266eba27f35de6ddcdb69332476e05e0046d32b06c`
- `ListingPurchased`: block `279651328`, tx `0x2ec3f1f3c820ce8db917cc266eba27f35de6ddcdb69332476e05e0046d32b06c`
- `NodeBurned`: block `279651499`, tx `0x4cf1587f18cad071b5e8b9225cba82787269a4ecac53d8b04de20cf2569bfb44`

## Verification

Latest relevant Rails verification before this evidence package:

- marketplace label/eligibility fix: full RSpec `529 examples, 0 failures, 3 pending`
- targeted marketplace request specs: passed
- RuboCop for touched marketplace files: passed

Latest required contract verification before mainnet deployment:

```sh
forge fmt --check
forge build
forge test --offline --no-auto-detect
```

## Mainnet Readiness

Sepolia rehearsal is complete and Arbitrum mainnet contracts are deployed.

Mainnet `NodeNFT`:

- address: `0x1fc8184a57bD61eAC3dFBE53D8B2712195C9926f`
- deployment tx: `0x04d284fccc8f75fe103499c159c9228b235679b85a4c075fd354da8702b2bda1`
- deployment block: `476087135`
- explorer: `https://arbiscan.io/address/0x1fc8184a57bD61eAC3dFBE53D8B2712195C9926f#code`

Mainnet `NodeNFTMarketplace`:

- address: `0x410b0037436d0b8468e1295dCbF3D86882ed6d7a`
- deployment tx: `0x7995bfcc8f38ed5aad027c171c6aa0bafae23c867919fe15a5a004b81795b863`
- deployment block: `476087478`
- constructor `NFT_CONTRACT`: `0x1fc8184a57bD61eAC3dFBE53D8B2712195C9926f`
- explorer: `https://arbiscan.io/address/0x410b0037436d0b8468e1295dCbF3D86882ed6d7a#code`

Production Rails mainnet config:

- active network: `arbitrum_mainnet`
- chain id: `42161`
- active `NodeNFT`: `0x1fc8184a57bD61eAC3dFBE53D8B2712195C9926f`
- active `NodeNFTMarketplace`: `0x410b0037436d0b8468e1295dCbF3D86882ed6d7a`
- sync cursor initialized through block `476089311`

Remaining Milestone 3 work is controlled mainnet smoke, controlled cohort launch, KPI tracking, and coordinated public announcement with Arbitrum.
