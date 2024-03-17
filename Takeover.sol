// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ITakeover } from "./interfaces/ITakeover.sol";
import { IOnChainOracle } from "./interfaces/IOnChainOracle.sol";
import { IOffChainOracle } from "./interfaces/IOffChainOracle.sol";
import { ITokenVesting } from "./interfaces/ITokenVesting.sol";
import { ITreasure } from "./interfaces/ITreasure.sol";

contract Takeover is ITakeover, Ownable {
    using SafeERC20 for IERC20;

    address immutable public token;
    address public tokenPool;

    IOnChainOracle public onchainOracle;
    IOffChainOracle public offchainOracle;

    ITokenVesting public vesting;
    ITreasure public treasure;

    bool public absorption;

    uint256 public duration = 7 days;
    uint256 public extraBonus;

    mapping(address => AbsorbedToken) public absorbedTokens;

    constructor(address _token, address _tokenPool, IOnChainOracle _onchainOracle, IOffChainOracle _offchainOracle, ITokenVesting _vesting, ITreasure _treasure) Ownable(msg.sender) {
        token = _token;
        tokenPool = _tokenPool;
        onchainOracle = _onchainOracle;
        offchainOracle = _offchainOracle;
        vesting = _vesting;
        treasure = _treasure;
    }

    function merge(address victim, uint256 victimAmount) external {
        AbsorbedToken memory victimToken = absorbedTokens[victim];

        if(!absorption) {
            revert TheAbsorptionIsNotActive();
        }

        if(!victimToken.active) {
            revert TheTokenCannotBeAbsorbed();
        }

        IERC20(victim).safeTransferFrom(msg.sender, address(treasure), victimAmount);

        uint160 sqrtPriceX96 = onchainOracle.getSqrtTwapX96(tokenPool, 1);
        uint256 mergePrice = onchainOracle.getPrice(sqrtPriceX96);

        uint80[] memory memcoinPrices = offchainOracle.decode();
        uint256 victimPrice = memcoinPrices[victimToken.number];
        uint256 victimTotalPrice = victimAmount * victimPrice;

        uint256 mergeAmount = (victimTotalPrice * 10**18) / mergePrice;

        vesting.createVestingSchedule(msg.sender, block.timestamp, 0, duration, 1, true, mergeAmount);

        emit Merge(msg.sender, victim, victimAmount, mergeAmount);
    }

    function updateAbsorbedToken(address victim, uint256 number, bool action) external onlyOwner {
        absorbedTokens[victim].number = number;
        absorbedTokens[victim].active = action;

        emit UpdateAbsorbedToken(victim, action);
    }

    function changeAbsorption(bool action) external onlyOwner {
        absorption = action;
    }

    function changeExtraBonus(uint256 _extraBonus) external onlyOwner {
        extraBonus = _extraBonus;
    }

    function changeOnChainOracle(IOnChainOracle _oracle) external onlyOwner {
        onchainOracle = _oracle;
    }

    function changeOffChainOracle(IOffChainOracle _oracle) external onlyOwner {
        offchainOracle = _oracle;
    }

    function changeVesting(ITokenVesting _vesting) external onlyOwner {
        vesting = _vesting;
    }

    function changeTreasure(ITreasure _treasure) external onlyOwner {
        treasure = _treasure;
    }
}
