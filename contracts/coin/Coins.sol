// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IERC20} from "./interfaces/IERC20.sol";

/// @notice contract for ERC20 token (Coins).
/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-20[ERC20] Non-Fungible Token Standardy as
 */
/// @title an implementation of ERC20 fungible token contract.
/// @author dchouhan-in@github.com
contract Coins is IERC20 {
    uint256 private _totalSupply;

    // token name
    string private _name;
    // token symbol
    string private _symbol;

    // contract owner, currently immutable
    address private _deployer;

    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256))
        private _allowances;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` and `deployer` to the token collection.
     */
    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _deployer = msg.sender;
        mint(msg.sender, 1000 * 1e18);
    }

    /// @dev Returns name of token
    function name() external view override returns (string memory) {
        return _name;
    }

    /// @dev Returns name of token
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /// @notice total tokens ever issued
    /// @dev Returns total supply
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /** 
     *  @dev Returns total decimals used in representation,
    i.e : if the balance of address is 1e17, it means the address owns .1 of the Coin.

    */
    function decimals() external pure returns (uint8) {
        return 18;
    }

    /// @dev returns balance of an address
    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    /// @dev transfers coins to the address
    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        require(_balances[msg.sender] >= value);

        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /// @notice returns the amount a third party spender can spend on address's behalf
    /// @dev returns allowance
    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /// @notice approve a third party spender can spend on address's behalf
    /// @dev approve spender
    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /// @dev transfer coins `from` address to `to` address, caller must be approved first.
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(_balances[from] >= value, "insufficient balance");
        require(
            _allowances[from][msg.sender] >= value,
            "insufficient balance!"
        );
        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    /** 
     @dev mints `_amount` number of coins to `to` address, only owner of contract i.e deployer, can mint.
     */
    function mint(address _to, uint256 _amount) public {
        require(msg.sender == _deployer, "only contract owner can mint!");
        _balances[_to] += _amount;
        _totalSupply += _amount;
    }
}
