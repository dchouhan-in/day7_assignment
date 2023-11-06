pragma solidity 0.8.20;

import "hardhat/console.sol";

contract TargetContract {
    mapping(address => uint256) public balances;

    constructor() payable {}

    function deposit() public payable {
        console.log(msg.sender, "<<<<<< test");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        balances[msg.sender] -= amount;
    }
}
