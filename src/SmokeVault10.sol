// SPDX-License-Identifier: MIT
// Smoke fixture for PR #10 — PAT + Checks:write probe (2026-10-06).
// Deliberate surface: reentrancy (high → gate breach), unzeroed sweep
// recipient (low → reported, not gated). NOT for production.
pragma solidity ^0.8.24;

/// @title SmokeVault10 — fresh-head smoke for the durable-token + check-run probe.
contract SmokeVault10 {
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
        balances[msg.sender] -= amount; // state updated after external call — reentrancy
    }

    function sweep(address to) external {
        require(msg.sender == owner, "only owner");
        (bool ok, ) = to.call{value: address(this).balance}(""); // unzeroed recipient
        require(ok, "sweep failed");
    }
}
