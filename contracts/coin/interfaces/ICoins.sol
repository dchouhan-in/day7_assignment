// SPDX-License-Identifier: UnLiscensed

pragma solidity 0.8.20;

interface ICoins {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
