// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NodeNFT is ERC721, AccessControl, EIP712 {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant MINT_AUTHORIZER_ROLE = keccak256("MINT_AUTHORIZER_ROLE");
    bytes32 public constant MINT_AUTHORIZATION_TYPEHASH = keccak256(
        "MintAuthorization(address to,uint256 nodeId,uint32 nodeType,uint64 subscriptionExpiry,bytes32 nonce,uint64 deadline)"
    );

    error AdminRequired();
    error OperatorRequired();
    error ToRequired();
    error NodeIdRequired();
    error NodeTypeRequired();
    error ExpiryInPast();
    error NodeAlreadyMinted();
    error TokenNotMinted();
    error ExpiryNotExtended();
    error BurnDisabled();
    error MintAuthorizationExpired();
    error MintNonceUsed();
    error MintSignerUnauthorized();

    struct NodeData {
        uint256 nodeId;
        uint32 nodeType;
        uint64 subscriptionExpiry;
    }

    struct MintAuthorization {
        address to;
        uint256 nodeId;
        uint32 nodeType;
        uint64 subscriptionExpiry;
        bytes32 nonce;
        uint64 deadline;
    }

    uint256 private _nextTokenId = 1;
    string private _baseTokenUri;

    mapping(uint256 tokenId => NodeData) private _nodeDataByTokenId;
    mapping(uint256 nodeId => uint256 tokenId) private _tokenIdByNodeId;
    mapping(bytes32 nonce => bool used) private _usedMintNonces;

    event BaseURIUpdated(string oldBaseURI, string newBaseURI);
    event NodeMinted(uint256 indexed tokenId, uint256 indexed nodeId, address indexed to);
    event SubscriptionExtended(uint256 indexed tokenId, uint64 oldExpiry, uint64 newExpiry);
    event NodeTransferSync(uint256 indexed nodeId, address indexed from, address indexed to);

    constructor(
        string memory name_,
        string memory symbol_,
        address admin,
        address operator,
        string memory baseTokenUri_
    ) ERC721(name_, symbol_) EIP712(name_, "1") {
        if (admin == address(0)) revert AdminRequired();
        if (operator == address(0)) revert OperatorRequired();

        _baseTokenUri = baseTokenUri_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, operator);
    }

    function mint(address to, uint256 nodeId, uint32 nodeType, uint64 subscriptionExpiry)
        external
        onlyRole(OPERATOR_ROLE)
        returns (uint256 tokenId)
    {
        tokenId = _mintNode(to, nodeId, nodeType, subscriptionExpiry);
    }

    function mintWithSignature(MintAuthorization calldata authorization, bytes calldata signature)
        external
        returns (uint256 tokenId)
    {
        if (authorization.deadline < block.timestamp) revert MintAuthorizationExpired();
        if (_usedMintNonces[authorization.nonce]) revert MintNonceUsed();

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MINT_AUTHORIZATION_TYPEHASH,
                    authorization.to,
                    authorization.nodeId,
                    authorization.nodeType,
                    authorization.subscriptionExpiry,
                    authorization.nonce,
                    authorization.deadline
                )
            )
        );
        address signer = ECDSA.recover(digest, signature);
        if (!hasRole(MINT_AUTHORIZER_ROLE, signer) && !hasRole(OPERATOR_ROLE, signer)) {
            revert MintSignerUnauthorized();
        }

        _usedMintNonces[authorization.nonce] = true;
        tokenId =
            _mintNode(authorization.to, authorization.nodeId, authorization.nodeType, authorization.subscriptionExpiry);
    }

    function usedMintNonces(bytes32 nonce) external view returns (bool used) {
        return _usedMintNonces[nonce];
    }

    function _mintNode(address to, uint256 nodeId, uint32 nodeType, uint64 subscriptionExpiry)
        private
        returns (uint256 tokenId)
    {
        if (to == address(0)) revert ToRequired();
        if (nodeId == 0) revert NodeIdRequired();
        if (nodeType == 0) revert NodeTypeRequired();
        if (subscriptionExpiry <= block.timestamp) revert ExpiryInPast();
        if (_tokenIdByNodeId[nodeId] != 0) revert NodeAlreadyMinted();

        tokenId = _nextTokenId++;
        _tokenIdByNodeId[nodeId] = tokenId;

        _nodeDataByTokenId[tokenId] =
            NodeData({nodeId: nodeId, nodeType: nodeType, subscriptionExpiry: subscriptionExpiry});

        _safeMint(to, tokenId);
        emit NodeMinted(tokenId, nodeId, to);
    }

    function extendSubscription(uint256 tokenId, uint64 newExpiry) external onlyRole(OPERATOR_ROLE) {
        if (_ownerOf(tokenId) == address(0)) revert TokenNotMinted();
        NodeData storage data = _nodeDataByTokenId[tokenId];
        if (newExpiry <= data.subscriptionExpiry) revert ExpiryNotExtended();
        if (newExpiry <= block.timestamp) revert ExpiryInPast();

        uint64 oldExpiry = data.subscriptionExpiry;
        data.subscriptionExpiry = newExpiry;
        emit SubscriptionExtended(tokenId, oldExpiry, newExpiry);
    }

    function nodeData(uint256 tokenId)
        external
        view
        returns (uint256 nodeId, uint32 nodeType, uint64 subscriptionExpiry)
    {
        if (_ownerOf(tokenId) == address(0)) revert TokenNotMinted();
        NodeData memory data = _nodeDataByTokenId[tokenId];
        return (data.nodeId, data.nodeType, data.subscriptionExpiry);
    }

    function tokenIdByNodeId(uint256 nodeId) external view returns (uint256 tokenId) {
        return _tokenIdByNodeId[nodeId];
    }

    function setBaseURI(string calldata newBaseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        string memory oldBaseURI = _baseTokenUri;
        _baseTokenUri = newBaseURI;
        emit BaseURIUpdated(oldBaseURI, newBaseURI);
    }

    function burn(uint256) external pure {
        revert BurnDisabled();
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenUri;
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address previousOwner) {
        previousOwner = super._update(to, tokenId, auth);

        if (previousOwner != address(0) && to != address(0)) {
            uint256 nodeId = _nodeDataByTokenId[tokenId].nodeId;
            emit NodeTransferSync(nodeId, previousOwner, to);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
