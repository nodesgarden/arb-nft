# Milestone 1 Evidence

This file records the public proof for Milestone 1 delivery.

## Deployment

- network: `Arbitrum Sepolia`
- chain id: `421614`
- deployed address: `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`
- deployment tx hash: `0x7932699a5dbfff24720dbbdf20026967a4274cef0b361a0383f6b3f687c2134e`
- verification URL: `https://sepolia.arbiscan.io/address/0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392#code`
- deployer address: `0x6a7A166806fCe320Cc7e0bE57628297482d75fd8`
- admin address: `0x73c9Bf1423b38FAd7Ee21A82dfa2991820D47024`
- operator address: `0xA3F00f3A194cDB68beA9082Ca55C10a06b72e314`
- base URI: `https://nodes.garden/api/nft/`

## Contract Version

- commit hash: `daf976e`
- contract path: `src/NodeNFT.sol:NodeNFT`

## Mint Activity

- target: `>= 100 testnet mints`
- actual mint count: `100`
- token id range: `1-100`
- backend dataset: synthetic production-backed demo rows under `user_id=1`, `project_id=56`, marker `arb_nft_m1_demo_20260329`
- batch file used: `script/examples/generated/milestone1-mint-batch.json`
- sample mint tx hashes:
  - `0x16dcf0874a766c5693b4679ff5ceafa9cb7958cf9d4f83dbc7eebb6332f9f5a9`
  - `0xf574cbd139db89d23e8a47f615fcc96bb913fc5f8fd54a0351301cc9e9f10c96`
  - `0x13007df0c1ae06351508f21cd5cc587b8d69f8bb7ce0457adeec1ee41e547402`

## Transfer Activity

- wallets used: `0x6a7A166806fCe320Cc7e0bE57628297482d75fd8`, `0xA3F00f3A194cDB68beA9082Ca55C10a06b72e314`, `0xdb1e0801529b900efA31aBC05fA922D91EfbCe94`
- transfer batch files used: `script/examples/generated/milestone1-transfer-deployer.json`, `script/examples/generated/milestone1-transfer-operator.json`, `script/examples/generated/milestone1-transfer-extra-owner.json`
- sample transfer tx hashes:
  - `0x636e2297833f9c0c766a5d218e54219e6d2d125715fa8e8817e6e9cad1291648`
  - `0x024b9695b715164fd3fd45115b8d609fbf73c802f33a83289b653a4d9e3185e6`
  - `0xdc05a7c408c8590722778f322db08b3c8027cbe4c157d050fb171882d473fce8`
- `NodeTransferSync` evidence: token `1` emitted node `25710`, token `35` emitted node `25744`, token `68` emitted node `25777`

## Metadata Evidence

- sample token URI 1: `https://nodes.garden/api/nft/1`
- sample token URI 2: `https://nodes.garden/api/nft/35`
- sample token URI 3: `https://nodes.garden/api/nft/68`
- sample metadata responses captured: token `1` -> node `25710`, node type `56`, status `active`; token `35` -> node `25744`, node type `56`, status `active`; token `68` -> node `25777`, node type `56`, status `active`

## Verification Checklist

- [x] contract deployed on Arbitrum Sepolia
- [x] explorer verification completed
- [x] 100+ testnet mints completed
- [x] representative multi-wallet transfers completed
- [x] metadata endpoint serves minted tokens
- [x] milestone artifacts recorded in this file
