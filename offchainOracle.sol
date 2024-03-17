// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Oracle is Ownable {

    /*
        Dogecoin
        Shiba Inu
        Pepe
        Floki
    */

    mapping(uint256 => uint256) public memcoinPrice; 

    constructor() Ownable(msg.sender) {}

    function encode(uint80[4] calldata prices) external onlyOwner{
        uint256 batch1 = uint256(prices[0]);
        batch1 |= uint256(prices[1]) << 85;
        batch1 |= uint256(prices[2]) << 170;
        
        uint256 batch2 = uint256(prices[3]);

        memcoinPrice[1] = batch1;
        memcoinPrice[2] = batch2;
    }

    function decode() external view returns (uint80[] memory result) {

        (result[0], result[1], result[2]) = _shard(memcoinPrice[1]);
        (result[3], , ) = _shard(memcoinPrice[2]);
    }

    function _shard(uint256 batch) internal pure returns(uint80,uint80,uint80) {
        uint80 price1 = uint80(batch);
        uint80 price2 = uint80(batch >> 85);
        uint80 price3 = uint80(batch >> 170);

        return(price1, price2, price3);
    }
}
