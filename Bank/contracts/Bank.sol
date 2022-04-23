// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Bank {
    event TransferLog(uint256 ammount, address from, address to);

    function transfer(uint256 _ammount, address _to) public {
        // function logic
        emit TransferLog(_ammount, msg.sender, _to);
    }
}
