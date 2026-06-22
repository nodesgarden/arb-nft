# Milestone 3 Submission Draft

Hi @Chilla, here is our Milestone 3 update:

We implemented the mainnet launch flow for nodes.garden Node NFTs, completed the Arbitrum Sepolia rehearsal end to end, deployed the contracts on Arbitrum mainnet, and switched production Rails to the mainnet contract configuration.

What shipped:

- signed, user-paid `Mint Node NFT` flow
- `Burn to Reveal Key` flow
- fixed-price Node NFT marketplace listing and purchase flow
- Rails event indexing for mints, transfers, listings, purchases, and burns
- private key/mnemonic masking until explicit reveal
- project-level mintability gating for newly purchased nodes
- demo activation path for testing newly purchased nodes without deploying real infrastructure

Sepolia rehearsal:

- fresh NodeNFT contract deployed and verified
- fresh marketplace contract deployed and verified
- real browser flow tested through nodes.garden:
  - purchase Dria node
  - activate test node for minting
  - mint NFT
  - list NFT
  - purchase from another user/wallet
  - verify backend ownership transfer
  - burn NFT and reveal keys
- Arbitrum mainnet contracts deployed and verified:
  - NodeNFT: `0x1fc8184a57bD61eAC3dFBE53D8B2712195C9926f`
  - Marketplace: `0x410b0037436d0b8468e1295dCbF3D86882ed6d7a`
- Production Rails is configured for `arbitrum_mainnet` with sync cursors initialized.

Links:

- Repo: `https://github.com/nodesgarden/arb-nft`
- NodeNFT: `https://sepolia.arbiscan.io/address/0xC31a939521Da80b4C3A9B47C863d66d9F3E9563F#code`
- Marketplace: `https://sepolia.arbiscan.io/address/0x1fD2d84E36cc2F3EDcb2d8d603602db0982eB7E0#code`
- Mainnet NodeNFT: `https://arbiscan.io/address/0x1fc8184a57bD61eAC3dFBE53D8B2712195C9926f#code`
- Mainnet marketplace: `https://arbiscan.io/address/0x410b0037436d0b8468e1295dCbF3D86882ed6d7a#code`
- Milestone evidence: `https://github.com/nodesgarden/arb-nft/blob/main/MILESTONE_3_EVIDENCE.md`

Representative UI smoke transactions:

- mint: `https://sepolia.arbiscan.io/tx/0x1fa3e5c8f64fa75cf749d54ec3dd81e44fca2b78e1a5b5af6c8b7d7710a93019`
- list: `https://sepolia.arbiscan.io/tx/0xa0849d8e4888cf134d5460a190e32f72c1757c843b1f5faaa77dfb5641c973c6`
- purchase: `https://sepolia.arbiscan.io/tx/0x2ec3f1f3c820ce8db917cc266eba27f35de6ddcdb69332476e05e0046d32b06c`
- burn/reveal: `https://sepolia.arbiscan.io/tx/0x4cf1587f18cad071b5e8b9225cba82787269a4ecac53d8b04de20cf2569bfb44`

Next step is controlled real mainnet smoke and cohort onboarding.
