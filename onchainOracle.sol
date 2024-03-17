// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { TickMath } from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import { FixedPoint96 } from "@uniswap/v3-core/contracts/libraries/FixedPoint96.sol";
import { FullMath } from "@uniswap/v3-core/contracts/libraries/FullMath.sol";

contract Oracle {

    uint private constant TWO_96 = 2 ** 96;

    function getSqrtTwapX96(address uniswapV3Pool, uint32 twapInterval) public view returns (uint160 sqrtPriceX96) {
        if (twapInterval == 0) {
            // return the current price if twapInterval == 0
            (sqrtPriceX96, , , , , , ) = IUniswapV3Pool(uniswapV3Pool).slot0();
        } else {
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = twapInterval; // from (before)
            secondsAgos[1] = 0; // to (now)

            (int56[] memory tickCumulatives, ) = IUniswapV3Pool(uniswapV3Pool).observe(secondsAgos);

            // tick(imprecise as it's an integer) to price
            sqrtPriceX96 = TickMath.getSqrtRatioAtTick(
                int24((tickCumulatives[1] - tickCumulatives[0]) / int32(twapInterval))
            );
        }
    }

    function getPriceX96FromSqrtPriceX96(uint160 sqrtPriceX96) public pure returns(uint256 priceX96) {
        return FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, FixedPoint96.Q96);
    }

    function getPrice(uint160 sqrtPriceX96) public pure returns (uint) {
        uint tokenInDecimals = 18;
        uint priceDigits = _countDigits(uint(sqrtPriceX96));
        uint precision = 10 ** ((priceDigits < 29 ? 29 - priceDigits : 0) + tokenInDecimals);
        uint part = uint(sqrtPriceX96) * precision / TWO_96;
        uint purePrice = part * part;
        return purePrice  / precision / (precision > 1e18 ? (precision / 1e18) : 1);
    }

    function _countDigits(uint n) internal pure returns (uint) {
        if (n == 0) {
        return 0;
        }
        uint count = 0;
        while (n != 0) {
        n = n / 10;
        ++count;
        }
            return count;
    }
}
