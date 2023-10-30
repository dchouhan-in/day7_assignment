// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IERC721} from "./interfaces/IERC721.sol";

contract Assets is IERC721 {
    uint private assetsCount = 0;

    address private _coins;

    constructor(address coins) {
        _coins = coins;
    }

    mapping(uint tokenId => Asset assetDetails) private _assets;

    mapping(address owner => uint) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool))
        private _operatorApprovals;

    struct Asset {
        address owner;
        uint price;
        bool price_set;
    }

    function _mint(uint assetsToMint) external {
        unchecked {
            for (uint i = assetsCount; i < assetsToMint + assetsCount; i++) {
                _assets[i] = Asset(msg.sender, 0, false);
                assetsCount += 1;
            }
        }

        _balances[msg.sender] += assetsToMint;
    }

    function _setPrice(uint asset_id, uint price) external {
        Asset storage _asset = _assets[asset_id];
        require(
            _asset.owner == msg.sender,
            "only owner of asset can set the price!"
        );
        _asset.price = price;
        _asset.price_set = true;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {
        return interfaceId == type(IERC721).interfaceId;
    }

    function balanceOf(
        address owner
    ) external view override returns (uint256 balance) {
        return _balances[owner];
    }

    function ownerOf(
        uint256 tokenId
    ) external view override returns (address owner) {
        return _assets[tokenId].owner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external override {
        require(to == address(0), "to address can't be 0x");
        _transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
    }

    function _revokeApprovals(uint tokenId) internal {
        _tokenApprovals[tokenId] = address(0);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(to != address(0), "to address can't be 0x");

        Asset storage asset = _assets[tokenId];

        require(asset.owner == from, "Invalid tokenId!");

        require(
            msg.sender == from ||
                _isApproved(msg.sender, tokenId) ||
                _isApprovedForAll(msg.sender, from),
            "Not approved for the transfer!"
        );

        _assets[tokenId].owner = to;
    }

    function _isApproved(
        address operator,
        uint tokenId
    ) internal view returns (bool) {
        return _tokenApprovals[tokenId] == operator;
    }

    function _isApprovedForAll(
        address operator,
        address owner
    ) internal view returns (bool) {
        return _operatorApprovals[owner][operator] == true;
    }

    function approve(address to, uint256 tokenId) external override {
        require(_assets[tokenId].owner == msg.sender, "Invalid TokenId!");

        _tokenApprovals[tokenId] = to;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        _operatorApprovals[msg.sender][operator] = true;
    }

    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function buy(uint tokenId) external returns (bool) {
        Asset storage asset = _assets[tokenId];
        require(asset.price_set == true, "price not set by owner!");
        _coins.transferFrom(msg.sender, address(this), asset.price);
        asset.owner = msg.sender;
        _revokeApprovals(tokenId);
        return true;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try to.onERC721Received(msg.sender, from, tokenId, data) returns (
                bytes4 retval
            ) {
                require(
                    retval != to.onERC721Received.selector,
                    "invalid receiver!"
                );
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("invalid receiver!");
                } else {
                    revert(reason);
                }
            }
        }
    }
}
