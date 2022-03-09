// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract HelloWorld{
    string public value;

    constructor(string memory initialValue){
        value = initialValue;
    }

    function changeValue(string memory newValue) public {
        value = newValue;
    }
}
