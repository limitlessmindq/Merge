// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ITreasure } from "./interfaces/ITreasure.sol";

contract Treasure is ITreasure, Ownable {

    constructor() Ownable(msg.sender) {}

    function withdrawTokens(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
        emit TokensWithdrawal(token, to, amount);

    }

    function withdrawNativeTokens(address to, uint256 amount) external onlyOwner {
        if(address(this).balance < amount) {
            revert InsufficientFunds();
        }
        
        payable(to).transfer(amount);
        emit NativeTokensWithdrawal(to, amount);
    }
    
    receive() external payable {
        emit FundsRecived(msg.sender, msg.value);
    }
    
    fallback() external payable {}
}
