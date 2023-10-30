// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC721} from "./interfaces/IERC721.sol";

contract Assets is IERC721 {
    uint private assetsCount = 0;

    address private _coins;

    struct Asset {
        address owner;
        uint price;
        bool price_set;
        address operator;
    }

    constructor(address coins) {
        _coins = coins;
    }

    mapping(uint tokenId => Asset assetDetails) private _assets;

    mapping(address owner => uint[] tokenIds) private _tokens;

    function _mint(uint assetsToMint) external {
        unchecked {
            for (uint i = assetsCount; i < assetsToMint + assetsCount; i++) {
                _assets[i] = Asset(msg.sender, 0, false, address(0));
                assetsCount += 1;
            }
        }
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
    ) external view override returns (bool) {}

    function balanceOf(
        address owner
    ) external view override returns (uint256 balance) {
        return _tokens[owner].length;
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
        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
    }

    // function _transferAll(
    //     address from,
    //     address to,
    //     uint[] memory tokenIds
    // ) internal {
    //     for (uint i = 0; i < tokenIds.length; i++) {
    //         _assets[tokenIds[i]].owner = to;
    //     }
    //     _tokens[to] = tokenIds;
    //     delete _tokens[from];
    // }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        Asset storage asset = _assets[tokenId];

        require(
            (_assets[tokenId].owner == from) &&
                (msg.sender == from || _assets[tokenId].operator == msg.sender),
            "only owner or operator can transfer!"
        );

        asset.owner = to;
        uint indexOfToken = _indexOf(tokenId, _tokens[from]);
        delete _tokens[from][indexOfToken];
        _tokens[to].push(tokenId);
    }

    function _indexOf(
        uint tokenId,
        uint[] memory tokens
    ) internal pure returns (uint) {
        unchecked {
            for (uint i = 0; i < tokens.length; i++) {
                if (tokens[i] == tokenId) {
                    return i;
                }
            }
        }
    }

    function approve(address to, uint256 tokenId) external override {
        require(
            _assets[tokenId].owner == msg.sender,
            "only owner of asset can approve!"
        );
        _assets[tokenId].operator = to;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        uint[] memory tokens = _tokens[msg.sender];
        unchecked {
            for (uint i = 0; i < tokens.length; i++) {
                _assets[tokens[i]].operator = operator;
            }
        }
    }

    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {
        return _assets[tokenId].operator;
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        uint[] storage tokens = _tokens[msg.sender];
        unchecked {
            for (uint i = 0; i < tokens.length; i++) {
                if (_assets[tokens[i]].operator == address(0)) {
                    return false;
                }
            }
            return true;
        }
    }

    function buy(uint tokenId) external returns (bool) {
        Asset storage asset = _assets[tokenId];
        require(asset.price_set == true, "price not set by owner!");
        _coins.transferFrom(msg.sender, address(this), asset.price);
        asset.owner = msg.sender;
        return true;
    }
}
