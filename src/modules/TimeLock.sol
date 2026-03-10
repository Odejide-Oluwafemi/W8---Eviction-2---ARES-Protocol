// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TimeLock is ReentrancyGuard {
    // Events
    event ProposalQueued(bytes32 indexed id, address target, uint256 value, bytes data, uint256 timestamp);

    error TimeLock__ProposalAlreadyExecuted();
    error TimeLock__PropossalCancelled();
    error TimeLock__InvalidProposal();
    error TimeLock__StillInTimeLock();
    error TimeLock__Unauthorized();

    struct QueuedProposal {
        address target;
        uint256 value;
        bytes data;
        uint256 executeAfter;
        bool executed;
        bool cancelled;
    }

    address controller;
    mapping(bytes32 id => QueuedProposal) private queuedProposal;
    uint256 private timeLockPeriod;

    constructor(address _controller, uint256 _timeLockPeriod) {
        controller = _controller;
        timeLockPeriod = _timeLockPeriod;
    }

    modifier onlyController() {
        if (msg.sender != controller) revert TimeLock__Unauthorized();
        _;
    }

    modifier onlyValidProposal(bytes32 id) {
        if (queuedProposal[id].target == address(0)) revert TimeLock__InvalidProposal();
        _;
    }

    function queueProposal(bytes32 id, address _target, uint256 _value, bytes calldata _data)
        external
        onlyController
        onlyValidProposal(id)
    {
        QueuedProposal memory proposal = queuedProposal[id];

        if (proposal.executed) revert TimeLock__ProposalAlreadyExecuted();

        proposal = QueuedProposal({
            target: _target,
            value: _value,
            data: _data,
            executeAfter: block.timestamp + timeLockPeriod,
            executed: false,
            cancelled: false
        });

        queuedProposal[id] = proposal;

        emit ProposalQueued(id, proposal.target, proposal.value, proposal.data, proposal.executeAfter);
    }

    function execute(bytes32 id) external onlyController onlyValidProposal(id) returns (bool, bytes memory) {
        QueuedProposal storage proposal = queuedProposal[id];

        if (proposal.executed) revert TimeLock__ProposalAlreadyExecuted();
        if (proposal.target == address(0)) revert TimeLock__InvalidProposal();
        if (proposal.cancelled) revert TimeLock__PropossalCancelled();
        if (block.timestamp < proposal.executeAfter) revert TimeLock__StillInTimeLock();

        proposal.executed = true;

        (bool success, bytes memory data) = proposal.target.call{value: proposal.value}(proposal.data);
        if (!success) revert TimeLock__InvalidProposal();

        return (success, data);
    }
}
