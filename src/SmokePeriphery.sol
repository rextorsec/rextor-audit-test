// SPDX-License-Identifier: MIT
// Smoke retrigger: D-track receipts run
pragma solidity ^0.8.24;

/// @title SmokePeriphery — smoke fixture for the D-track receipts run.
contract SmokePeriphery {
    address public owner;
    mapping(address => uint256) public deposits;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = deposits[msg.sender];
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
        deposits[msg.sender] = 0;
    }

    function setOwner(address next) external {
        owner = next;
    }
}
