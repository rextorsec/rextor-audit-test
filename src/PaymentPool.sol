// SPDX-License-Identifier: MIT
// R6/E2 verdict-quality receipt fixture — fresh PR 2026-09-25.
// Deliberate surface: reentrancy (high → gate breach) + missing zero-check
// (low → reported, not gate-breaching). Same deterministic family as the
// proven SmokeVault fixture, fresh contract for a fresh reviewId.
pragma solidity ^0.8.24;

/// @title PaymentPool — E2 verdict-receipt fixture.
contract PaymentPool {
    address public admin;
    mapping(address => uint256) public credits;

    constructor() {
        admin = msg.sender;
    }

    function deposit() external payable {
        credits[msg.sender] += msg.value;
    }

    // reentrancy-eth: payout fires before the ledger clears.
    function withdraw() external {
        uint256 due = credits[msg.sender];
        (bool sent, ) = msg.sender.call{value: due}("");
        require(sent, "payout failed");
        credits[msg.sender] = 0;
    }

    // missing-zero-check: grant target is never validated.
    function grant(address to, uint256 amount) external {
        credits[to] += amount;
    }
}

// payout ceiling: single-beneficiary pool
// receipt run: auto-feedback verification
