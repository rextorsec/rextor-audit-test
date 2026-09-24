// SPDX-License-Identifier: MIT
// D-track full-loop smoke fixture — fresh PR 2026-09-22.
// Deliberate surface: reentrancy (high → gate breach), missing zero-check
// (low → dismissed from gate via rextor.yaml, still reported).
pragma solidity ^0.8.24;

/// @title SmokeVault — full-loop smoke fixture (gate + fix-diff + dismissals).
contract SmokeVault {
    address public owner;
    mapping(address => uint256) public shares;

    constructor() {
        owner = msg.sender;
    }

    function stake() external payable {
        shares[msg.sender] += msg.value;
    }

    // reentrancy-eth: external call precedes the state clear.
    function unstake() external {
        uint256 amount = shares[msg.sender];
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
        shares[msg.sender] = 0;
    }

    // missing-zero-check: mint recipient is never checked for zero.
    function mintTo(address who, uint256 amount) external {
        shares[who] += amount;
    }
}
