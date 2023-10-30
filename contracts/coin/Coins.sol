// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {IERC20} from "./interfaces/IERC20.sol";

contract Coins is IERC20 {
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _deployer;

    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _deployer = msg.sender;
        _mint(msg.sender, 1000);
    }

    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256))
        private _allowances;

    function _mint(address _to, uint256 _amount) public {
        require(msg.sender == _deployer, "only contract owner can mint!");
        _balances[_to] += _amount * 10e18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        require(_balances[msg.sender] >= value);

        _balances[msg.sender] -= value;
        _balances[to] += value;
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        _allowances[msg.sender][spender] = value;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        require(_allowances[from][msg.sender] >= value);
        _balances[from] -= value;
        _balances[to] += value;
        return true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }
}
