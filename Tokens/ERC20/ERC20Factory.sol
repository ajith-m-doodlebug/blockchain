/*
This implementation is done by Ajith @ ontheether.com
.*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/ajith-m-doodlebug/blockchain/blob/main/Tokens/ERC-20.sol";

contract ERC20Factory{

    mapping(address => address[]) public createdERC20s;

    constructor() {
        ERC20 newToken = new ERC20(100,"SAM",1,"SU");
        createdERC20s[msg.sender].push(address(newToken));
        newToken.transfer(msg.sender, newToken.balanceOf(msg.sender));
    }

    function getTokenContractAddress() public view returns (address[] memory contractAddress){
        return createdERC20s[msg.sender];
    }

}
