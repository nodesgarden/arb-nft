// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract NodeNFT is ERC721, AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct NodeData {
        uint256 nodeId;
        uint32 nodeType;
        uint64 subscriptionExpiry;
    }

    uint256 private _nextTokenId = 1;
    string private _baseTokenURI;

    mapping(uint256 tokenId => NodeData) private _nodeDataByTokenId;
    mapping(uint256 nodeId => uint256 tokenId) private _tokenIdByNodeId;

    event NodeMinted(uint256 indexed tokenId, uint256 indexed nodeId, address indexed to);
    event SubscriptionExtended(uint256 indexed tokenId, uint64 oldExpiry, uint64 newExpiry);
    event NodeTransferSync(uint256 indexed nodeId, address indexed from, address indexed to);

    constructor(
        string memory name_,
        string memory symbol_,
        address admin,
        address operator,
        string memory baseTokenURI_
    ) ERC721(name_, symbol_) {
        require(admin != address(0), "ADMIN_REQUIRED");
        require(operator != address(0), "OPERATOR_REQUIRED");

        _baseTokenURI = baseTokenURI_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, operator);
    }

    function mint(
        address to,
        uint256 nodeId,
        uint32 nodeType,
        uint64 subscriptionExpiry
    ) external onlyRole(OPERATOR_ROLE) returns (uint256 tokenId) {
        require(to != address(0), "TO_REQUIRED");
        require(nodeId != 0, "NODE_ID_REQUIRED");
        require(subscriptionExpiry > block.timestamp, "EXPIRY_IN_PAST");
        require(_tokenIdByNodeId[nodeId] == 0, "NODE_ALREADY_MINTED");

        tokenId = _nextTokenId++;
        _tokenIdByNodeId[nodeId] = tokenId;

        _nodeDataByTokenId[tokenId] = NodeData({
            nodeId: nodeId,
            nodeType: nodeType,
            subscriptionExpiry: subscriptionExpiry
        });

        _safeMint(to, tokenId);
        emit NodeMinted(tokenId, nodeId, to);
    }

    function extendSubscription(
        uint256 tokenId,
        uint64 newExpiry
    ) external onlyRole(OPERATOR_ROLE) {
        require(_ownerOf(tokenId) != address(0), "TOKEN_NOT_MINTED");
        NodeData storage data = _nodeDataByTokenId[tokenId];
        require(newExpiry > data.subscriptionExpiry, "EXPIRY_NOT_EXTENDED");
        require(newExpiry > block.timestamp, "EXPIRY_IN_PAST");

        uint64 oldExpiry = data.subscriptionExpiry;
        data.subscriptionExpiry = newExpiry;
        emit SubscriptionExtended(tokenId, oldExpiry, newExpiry);
    }

    function nodeData(
        uint256 tokenId
    ) external view returns (uint256 nodeId, uint32 nodeType, uint64 subscriptionExpiry) {
        require(_ownerOf(tokenId) != address(0), "TOKEN_NOT_MINTED");
        NodeData memory data = _nodeDataByTokenId[tokenId];
        return (data.nodeId, data.nodeType, data.subscriptionExpiry);
    }

    function tokenIdByNodeId(uint256 nodeId) external view returns (uint256 tokenId) {
        return _tokenIdByNodeId[nodeId];
    }

    function setBaseURI(string calldata newBaseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = newBaseURI;
    }

    function burn(uint256) external pure {
        revert("BURN_DISABLED");
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address previousOwner) {
        previousOwner = super._update(to, tokenId, auth);

        if (previousOwner != address(0) && to != address(0)) {
            uint256 nodeId = _nodeDataByTokenId[tokenId].nodeId;
            emit NodeTransferSync(nodeId, previousOwner, to);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
