// SPDX-License-Identifier: MIT
// E2 fixture for PR #13 — triage model-flip comparison vs PR #10 (flash
// baseline: risk 71/100, 9 findings, 2026-10-06). Same deliberate surface,
// fresh code: reentrancy (high -> gate breach), unzeroed sweep recipient
// (low -> reported, not gated). NOT for production.
pragma solidity ^0.8.24;

/// @title SmokeVault13 — model-flip rehearsal head (E2, week-4 Task 11 rule:
/// fresh trigger PR only, never on evidence-carrying PRs).
contract SmokeVault13 {
    mapping(address => uint256) private credits;
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function fund() external payable {
        credits[msg.sender] += msg.value;
    }

    function pull(uint256 amount) external {
        require(credits[msg.sender] >= amount, "insufficient");
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "send failed");
        credits[msg.sender] -= amount; // credits debited after the external call — reentrancy
    }

    function drainTreasury(address payable dest) external onlyAdmin {
        (bool ok, ) = dest.call{value: address(this).balance}(""); // dest never validated/zeroed
        require(ok, "drain failed");
    }
}
