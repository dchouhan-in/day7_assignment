pragma solidity 0.8.20;

import {Coins} from "../coin/Coins.sol";
import "hardhat/console.sol";

contract WETH is Coins {
    constructor() Coins("dummy wrapped ether", "WETH") {}

    function mint(address _to, uint256 _amount) public override {}

    function deposit() public payable {
        require(msg.value > 10e8, "atleast 10e8 wei must be sent!");
        uint _amount = msg.value / 10e8;
        _balances[msg.sender] += _amount;
        _totalSupply += _amount;
    }

    function withdraw(uint256 amount) public payable {
        uint _amount = amount * 10e8;
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
