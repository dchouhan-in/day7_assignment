// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IERC721Receiver} from "./interfaces/IERC721Receiver.sol";
import {ICoins} from "./interfaces/ICoins.sol";
import {IERC721} from "./interfaces/IERC721.sol";
import "hardhat/console.sol";

contract Assets is IERC721 {
    uint private _assetsCount = 0;

    address private _coins;

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

    constructor(address coins) {
        _coins = coins;
    }

    function mint(uint assetsToMint) external {
        uint totalToMint = assetsToMint + _assetsCount;
        for (uint i = _assetsCount; i < totalToMint; i++) {
            _assets[i] = Asset(msg.sender, 0, false);
            _assetsCount += 1;
        }

        _balances[msg.sender] += assetsToMint;
    }

    function setPrice(uint asset_id, uint price) external {
        Asset storage _asset = _assets[asset_id];
        require(
            _asset.owner == msg.sender,
            "only owner of asset can set the price!"
        );
        _asset.price = price;
        _asset.price_set = true;
    }

    function getPrice(uint asset_id) external view returns (uint) {
        Asset storage _asset = _assets[asset_id];
        return _asset.price;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
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

    function approve(address to, uint256 tokenId) external override {
        require(_assets[tokenId].owner == msg.sender, "Invalid TokenId!");
        _tokenApprovals[tokenId] = to;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        _operatorApprovals[msg.sender][operator] = approved;
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

        ICoins(_coins).transferFrom(msg.sender, address(this), asset.price);
        _transferFrom(asset.owner, msg.sender, tokenId);

        return true;
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                require(
                    retval != IERC721Receiver(to).onERC721Received.selector,
                    "invalid receiver!"
                );
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("invalid receiver!");
                } else {
                    revert(string(reason));
                }
            }
        }
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
        _balances[from] -= 1;
        _balances[to] += 1;
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
}
