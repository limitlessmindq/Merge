// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface ITakeover {
    
    struct AbsorbedToken {
        uint256 number;
        bool active;
    }
    
    event Merge(address indexed user, address indexed victim, uint256 victimAmount, uint256 mergeAmount);
    event UpdateAbsorbedToken(address indexed victim, bool action);

    error TheTokenCannotBeAbsorbed();
    error TheAbsorptionIsNotActive();
}
