// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Merge is OFT, ERC20Permit {
    constructor(
        uint256 _totalSupply, // token totalSupply
        address _layerZeroEndpoint // local endpoint address
    ) OFT("Merge", "MERGE", _layerZeroEndpoint, msg.sender) ERC20Permit("Merge") Ownable(msg.sender) {
        _mint(msg.sender, _totalSupply); 
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
