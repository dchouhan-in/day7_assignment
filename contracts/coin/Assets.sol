// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IERC721Receiver} from "./interfaces/IERC721Receiver.sol";
import {ICoins} from "./interfaces/ICoins.sol";
import {IERC721} from "./interfaces/IERC721.sol";

/// @notice contract for ERC721 token (Assets).
/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
/// @title an implementation of ERC721 fungible token contract.
/// @author dchouhan-in@github.com
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

    /// @dev initializes Assets contract, by setting address of pre deployed `Coins` contract
    constructor(address coins) {
        _coins = coins;
    }

    /// @notice mints Assets to the caller, price has to be set later on
    /// @dev mints Assets to the caller
    function mint(uint assetsToMint) external {
        uint totalToMint = assetsToMint + _assetsCount;
        for (uint i = _assetsCount; i < totalToMint; i++) {
            _assets[i] = Asset(msg.sender, 0, false);
            _assetsCount += 1;
        }

        _balances[msg.sender] += assetsToMint;
    }

    /// @notice set price of the asset of the owner, only owner can set price of the asset, asset price can be 0 as well.
    /// @dev set price of the asset.
    function setPrice(uint asset_id, uint price) external {
        Asset storage _asset = _assets[asset_id];
        require(
            _asset.owner == msg.sender,
            "only owner of asset can set the price!"
        );
        _asset.price = price;
        _asset.price_set = true;
    }

    /// @notice get price of the asset
    /// @dev get price of the asset
    function getPrice(uint asset_id) external view returns (uint) {
        Asset storage _asset = _assets[asset_id];
        return _asset.price;
    }

    /// @dev check if the `interfaceId` is supported
    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId;
    }

    /// @notice returns balance, of the token `owner` address. it returns the number of tokens the address owns
    /// @dev returns balance of `owner`
    function balanceOf(
        address owner
    ) external view override returns (uint256 balance) {
        return _balances[owner];
    }

    /// @notice returns owner of token
    /// @dev returns owner of `tokenId`
    function ownerOf(
        uint256 tokenId
    ) external view override returns (address owner) {
        return _assets[tokenId].owner;
    }

    /// @notice safe transfers token from one address to another, caller needs to be approved beforehand.
    /// @dev safe transfers token with `tokenId`, from `from` address to `to` address.
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

    /// @notice safe transfers token from one address to another, caller needs to be approved beforehand.
    /// @dev safe transfers token with `tokenId`, from `from` address to `to` address.
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, "");
    }

    /// @notice transfers token from one address to another, caller needs to be approved beforehand.
    /// @dev transfers token with `tokenId`, from `from` address to `to` address.
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override {
        _transferFrom(from, to, tokenId);
    }

    /// @notice approve address to transfer token in owner's behalf
    /// @dev approve `to` address to transfer token with `tokenId` in owner's behalf
    function approve(address to, uint256 tokenId) external override {
        require(_assets[tokenId].owner == msg.sender, "Invalid TokenId!");
        _tokenApprovals[tokenId] = to;
        emit Approval(_assets[tokenId].owner, to, tokenId);
    }

    /// @notice approve for entire tokens of the owner
    /// @dev approve `operator` for entire tokens of the owner.
    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice get approved operator of the token
    /// @dev get operator of the token, returns `0x` for none.
    function getApproved(
        uint256 tokenId
    ) external view override returns (address operator) {
        return _tokenApprovals[tokenId];
    }

    /// @notice check if an operator is approved for all tokens of the owner address
    /// @dev check if an operator is approved for all tokens of the owner address, returns (bool)
    function isApprovedForAll(
        address owner,
        address operator
    ) external view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @notice buy Assets in exchange of Coins, buyer needs to have sufficient balance in your Coins address.
     * also buyer needs to approve this contract address in Coins contract.
     */
    /// @dev buy Asset with `tokenId` in exchange of Coins, buyer needs to have sufficient balance in your Coins address.
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
        emit Transfer(from, to, tokenId);
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
