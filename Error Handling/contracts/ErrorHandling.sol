// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ErrorHandling{

    uint public numberOne = 15;
    uint public numberTwo = 1;

    function errorRequire() public view  {
        require(numberOne > numberTwo, "The number one should be greater than number two.");
    }

    function errorRevert() public view  {
        if(numberOne < numberTwo){
            revert("The number one should be greater than number two.");
        }
    }

    function errorAssert() public view {
        assert(numberOne == 15);
    }

}
