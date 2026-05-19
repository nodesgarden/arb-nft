# Milestone 3 Mainnet Contracts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and deploy the Arbitrum Mainnet `NodeNFT` contract with signed user-paid minting, owner burn-to-reveal support, and a mainnet marketplace.

**Architecture:** Keep settlement logic in `arb-nft`. Replace operator-only user minting with an EIP-712 authorization flow, while preserving operator subscription extension. Reuse the fixed-price escrow marketplace unless fee support is explicitly requested later.

**Tech Stack:** Solidity, Foundry, OpenZeppelin ERC721/AccessControl/EIP712, Arbitrum Mainnet, Arbiscan verification.

---

## File Map

- Modify: `src/NodeNFT.sol` - add EIP-712 mint authorization, nonce tracking, burn support, and `NodeBurned`.
- Modify: `test/NodeNFT.t.sol` or create `test/NodeNFTMainnetMintBurn.t.sol` - cover signed mint and burn behavior.
- Modify: `script/DeployNodeNFT.s.sol` - make mainnet deployment env names explicit.
- Create: `script/DeployMainnetNodeNFT.s.sol` only if existing deploy script cannot stay clean for both networks.
- Modify: `script/DeployNodeNFTMarketplace.s.sol` - ensure it works with mainnet `NFT_CONTRACT`.
- Modify: `foundry.toml` if mainnet profile/remapping is needed.
- Modify later: `CONTRACT_SPEC.md`, `DEPLOYMENT.md`, `README.md`.

## Task 1: Add Signed Mint Authorization

**Files:**
- Modify: `src/NodeNFT.sol`
- Test: `test/NodeNFTMainnetMintBurn.t.sol`

- [ ] **Step 1: Write failing tests for signed mint**

Test cases:
- valid backend/operator signature mints to the requested wallet
- signature is bound to `to`, `nodeId`, `nodeType`, `subscriptionExpiry`, `nonce`, `deadline`
- replaying the same nonce fails
- expired signature fails
- signature from non-authorized signer fails
- zero `to`, zero `nodeId`, zero `nodeType`, past expiry still fail

- [ ] **Step 2: Run test to verify failure**

Run:

```sh
forge test --offline --no-auto-detect --match-contract NodeNFTMainnetMintBurn -vvv
```

Expected: fail because `mintWithSignature` and nonce handling do not exist.

- [ ] **Step 3: Implement EIP-712 typed mint**

Contract shape:

```solidity
bytes32 public constant MINT_AUTHORIZER_ROLE = keccak256("MINT_AUTHORIZER_ROLE");

struct MintAuthorization {
    address to;
    uint256 nodeId;
    uint32 nodeType;
    uint64 subscriptionExpiry;
    bytes32 nonce;
    uint64 deadline;
}

function mintWithSignature(MintAuthorization calldata authorization, bytes calldata signature) external returns (uint256);
function usedMintNonces(bytes32 nonce) external view returns (bool);
```

Implementation requirements:
- inherit `EIP712`
- signer must have `MINT_AUTHORIZER_ROLE` or `OPERATOR_ROLE`
- set nonce used before mint side effects
- include `block.chainid` and verifying contract via EIP-712 domain
- emit existing `NodeMinted`

- [ ] **Step 4: Run signed mint tests**

Run:

```sh
forge test --offline --no-auto-detect --match-contract NodeNFTMainnetMintBurn -vvv
```

Expected: all signed mint tests pass.

- [ ] **Step 5: Run full contract suite**

Run:

```sh
forge fmt
forge build
forge test --offline --no-auto-detect
```

Expected: full suite passes.

- [ ] **Step 6: Commit**

```sh
git add src/NodeNFT.sol test/NodeNFTMainnetMintBurn.t.sol
git commit -m "Add signed NodeNFT mint authorization"
```

## Task 2: Add Burn To Reveal Event

**Files:**
- Modify: `src/NodeNFT.sol`
- Test: `test/NodeNFTMainnetMintBurn.t.sol`

- [ ] **Step 1: Write failing burn tests**

Test cases:
- token owner can burn
- approved operator can burn
- unrelated wallet cannot burn
- burn emits `NodeBurned(tokenId, nodeId, owner)`
- burned token no longer exists
- `tokenIdByNodeId(nodeId)` is cleared or made unusable
- same `nodeId` cannot be reminted after burn

- [ ] **Step 2: Run test to verify failure**

Run:

```sh
forge test --offline --no-auto-detect --match-test testOwnerCanBurnToReveal -vvv
```

Expected: fail because burn still reverts.

- [ ] **Step 3: Implement burn**

Contract shape:

```solidity
event NodeBurned(uint256 indexed tokenId, uint256 indexed nodeId, address indexed owner);
mapping(uint256 => bool) private _burnedNodeIds;
```

Rules:
- caller must be owner or approved
- capture owner and `nodeId` before burn
- clear token data
- mark `nodeId` burned so it cannot be minted again
- emit `NodeBurned`

- [ ] **Step 4: Run burn tests**

Run:

```sh
forge test --offline --no-auto-detect --match-contract NodeNFTMainnetMintBurn -vvv
```

Expected: pass.

- [ ] **Step 5: Run full suite**

```sh
forge fmt
forge build
forge test --offline --no-auto-detect
```

Expected: pass.

- [ ] **Step 6: Commit**

```sh
git add src/NodeNFT.sol test/NodeNFTMainnetMintBurn.t.sol
git commit -m "Enable NodeNFT burn reveal events"
```

## Task 3: Mainnet Deployment Scripts

**Files:**
- Modify: `script/DeployNodeNFT.s.sol`
- Modify: `script/DeployNodeNFTMarketplace.s.sol`
- Optional create: `script/DeployMainnetNodeNFT.s.sol`
- Test: `test/DeploymentConfig.t.sol` if script assertions are useful

- [ ] **Step 1: Inspect current deployment scripts**

Run:

```sh
sed -n '1,220p' script/DeployNodeNFT.s.sol
sed -n '1,220p' script/DeployNodeNFTMarketplace.s.sol
```

- [ ] **Step 2: Add required env validation**

Required mainnet env:
- `ARB_MAINNET_RPC_URL`
- `DEPLOYER_PRIVATE_KEY`
- `ETHERSCAN_API_KEY`
- `ADMIN_ADDRESS`
- `OPERATOR_ADDRESS`
- `MINT_AUTHORIZER_ADDRESS`
- `NFT_NAME`
- `NFT_SYMBOL`
- `BASE_URI`

- [ ] **Step 3: Add role grant in deploy script**

Deploy script must grant:
- `DEFAULT_ADMIN_ROLE` to admin constructor value
- `OPERATOR_ROLE` to operator constructor value
- `MINT_AUTHORIZER_ROLE` to backend signer

- [ ] **Step 4: Dry run locally**

Run:

```sh
forge script script/DeployNodeNFT.s.sol:DeployNodeNFT --rpc-url "$ARB_MAINNET_RPC_URL" -vvv
```

Expected: simulated deployment succeeds. No `--broadcast`.

- [ ] **Step 5: Commit**

```sh
git add script/DeployNodeNFT.s.sol script/DeployNodeNFTMarketplace.s.sol
git commit -m "Prepare mainnet deployment scripts"
```

## Task 4: Deploy And Verify Mainnet Contracts

**Files:**
- Modify: `DEPLOYMENT.md`
- Modify: `MILESTONE_3_EVIDENCE.md` after deployment

- [ ] **Step 1: Preflight**

Run:

```sh
forge fmt --check
forge build
forge test --offline --no-auto-detect
```

Expected: pass.

- [ ] **Step 2: Deploy NodeNFT**

Run:

```sh
forge script script/DeployNodeNFT.s.sol:DeployNodeNFT \
  --rpc-url "$ARB_MAINNET_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --broadcast \
  --verify \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  -vvv
```

Record:
- contract address
- deploy tx
- deployment block
- admin/operator/mint authorizer addresses
- verification URL

- [ ] **Step 3: Deploy marketplace**

Set:

```sh
export NFT_CONTRACT="<mainnet NodeNFT address>"
```

Run:

```sh
forge script script/DeployNodeNFTMarketplace.s.sol:DeployNodeNFTMarketplace \
  --rpc-url "$ARB_MAINNET_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --broadcast \
  --verify \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  -vvv
```

Record marketplace address, deploy tx, deployment block, and verification URL.

- [ ] **Step 4: Commit deployment evidence**

```sh
git add DEPLOYMENT.md MILESTONE_3_EVIDENCE.md
git commit -m "Record mainnet contract deployment"
```

## Acceptance Checks

- [ ] Signed mint works on a fork or mainnet smoke test.
- [ ] Burn emits `NodeBurned`.
- [ ] Marketplace lists only active subscriptions.
- [ ] Contracts verified on Arbiscan.
- [ ] No private keys or RPC secrets committed.
