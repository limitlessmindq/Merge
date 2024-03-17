// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOffChainOracle {
    function decode() external view returns (uint80[] memory result);
}
