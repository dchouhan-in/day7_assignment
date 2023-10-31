pragma solidity 0.8.20;

import {Coins} from "../coin/Coins.sol";

contract WETH is Coins {
    constructor() Coins("wrapped ether", "WETH") {}

    function mint(address _to, uint256 _amount) public override {}

    function deposit() public payable {
        uint _amount = msg.value * 10;
        _balances[msg.sender] += _amount;
        _totalSupply += _amount;
    }

    function withdraw(uint256 amount) public payable {
        uint _amount = amount / 10;
        require(_balances[msg.sender] >= amount, "insufficient balance!");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        bool status = payable(msg.sender).send(_amount);
        require(status == true, "caller cannot receive amount!");
    }

    function decimals() external pure override returns (uint8) {
        return 10;
    }
}
