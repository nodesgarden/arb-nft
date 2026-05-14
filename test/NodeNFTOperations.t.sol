// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {NodeNFTOperationsHarness} from "./harnesses/NodeNFTOperationsHarness.sol";

contract NodeNFTOperationsTest is Test {
    NodeNFTOperationsHarness private harness;

    function setUp() public {
        harness = new NodeNFTOperationsHarness();
    }

    function testReadMintBatchParsesExampleFile() public view {
        (
            address[] memory recipients,
            uint256[] memory nodeIds,
            uint256[] memory nodeTypes,
            uint256[] memory subscriptionExpiries
        ) = harness.readMintBatch("script/examples/mint-batch.example.json");

        assertEq(recipients.length, 3);
        assertEq(recipients[0], address(0x1001));
        assertEq(nodeIds[1], 25239);
        assertEq(nodeTypes[2], 3);
        assertEq(subscriptionExpiries[0], 1_800_000_000);
    }

    function testReadTransferBatchParsesExampleFile() public view {
        (address[] memory recipients, uint256[] memory tokenIds) =
            harness.readTransferBatch("script/examples/transfer-batch.example.json");

        assertEq(recipients.length, 3);
        assertEq(recipients[2], address(0x2003));
        assertEq(tokenIds[0], 1);
        assertEq(tokenIds[2], 3);
    }

    function testReadMarketplaceListingBatchParsesExampleFile() public view {
        (uint256[] memory tokenIds, uint256[] memory pricesWei) =
            harness.readMarketplaceListingBatch("script/examples/marketplace-listings.example.json");

        assertEq(tokenIds.length, 3);
        assertEq(tokenIds[0], 1);
        assertEq(tokenIds[2], 3);
        assertEq(pricesWei[0], 0.001 ether);
        assertEq(pricesWei[2], 0.003 ether);
    }

    function testReadMarketplaceBuyBatchParsesExampleFile() public view {
        (uint256[] memory listingIds, uint256[] memory pricesWei) =
            harness.readMarketplaceBuyBatch("script/examples/marketplace-buys.example.json");

        assertEq(listingIds.length, 2);
        assertEq(listingIds[0], 1);
        assertEq(listingIds[1], 2);
        assertEq(pricesWei[0], 0.001 ether);
        assertEq(pricesWei[1], 0.002 ether);
    }

    function testReadMarketplaceCancellationBatchParsesExampleFile() public view {
        uint256[] memory listingIds =
            harness.readMarketplaceCancellationBatch("script/examples/marketplace-cancellations.example.json");

        assertEq(listingIds.length, 3);
        assertEq(listingIds[0], 1);
        assertEq(listingIds[2], 3);
    }

    function testReadMintBatchRejectsLengthMismatch() public {
        vm.expectRevert(abi.encodeWithSignature("BatchLengthMismatch()"));
        harness.readMintBatch("script/examples/mint-batch.invalid.json");
    }

    function testReadMintBatchRejectsNodeTypeOverflow() public {
        vm.expectRevert(abi.encodeWithSignature("NodeTypeOutOfRange(uint256)", uint256(type(uint32).max) + 1));
        harness.readMintBatch("script/examples/mint-batch.node-type-overflow.json");
    }

    function testReadMintBatchRejectsSubscriptionExpiryOverflow() public {
        vm.expectRevert(abi.encodeWithSignature("SubscriptionExpiryOutOfRange(uint256)", uint256(type(uint64).max) + 1));
        harness.readMintBatch("script/examples/mint-batch.expiry-overflow.json");
    }

    function testReadTransferBatchRejectsLengthMismatch() public {
        vm.expectRevert(abi.encodeWithSignature("BatchLengthMismatch()"));
        harness.readTransferBatch("script/examples/transfer-batch.invalid.json");
    }

    function testReadMarketplaceListingBatchRejectsLengthMismatch() public {
        vm.expectRevert(abi.encodeWithSignature("BatchLengthMismatch()"));
        harness.readMarketplaceListingBatch("script/examples/marketplace-listings.invalid.json");
    }

    function testReadMarketplaceListingBatchRejectsZeroPrice() public {
        vm.expectRevert(abi.encodeWithSignature("PriceRequired()"));
        harness.readMarketplaceListingBatch("script/examples/marketplace-listings.zero-price.json");
    }

    function testReadMarketplaceBuyBatchRejectsLengthMismatch() public {
        vm.expectRevert(abi.encodeWithSignature("BatchLengthMismatch()"));
        harness.readMarketplaceBuyBatch("script/examples/marketplace-buys.invalid.json");
    }

    function testReadMarketplaceCancellationBatchRejectsEmptyBatch() public {
        vm.expectRevert(abi.encodeWithSignature("EmptyBatch()"));
        harness.readMarketplaceCancellationBatch("script/examples/marketplace-cancellations.empty.json");
    }
}
