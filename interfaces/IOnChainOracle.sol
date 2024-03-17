// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOnChainOracle {
    function getSqrtTwapX96(address uniswapV3Pool, uint32 twapInterval) external view returns (uint160 sqrtPriceX96);

    function getPriceX96FromSqrtPriceX96(uint160 sqrtPriceX96) external pure returns(uint256 priceX96);

    function getPrice(uint160 sqrtPriceX96) external pure returns (uint);
}
