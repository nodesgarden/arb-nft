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

    function testReadMintBatchRejectsLengthMismatch() public {
        vm.expectRevert(abi.encodeWithSignature("BatchLengthMismatch()"));
        harness.readMintBatch("script/examples/mint-batch.invalid.json");
    }

    function testReadTransferBatchRejectsLengthMismatch() public {
        vm.expectRevert(abi.encodeWithSignature("BatchLengthMismatch()"));
        harness.readTransferBatch("script/examples/transfer-batch.invalid.json");
    }
}
