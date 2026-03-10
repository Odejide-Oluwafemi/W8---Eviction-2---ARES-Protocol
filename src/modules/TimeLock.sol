// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TimeLock is ReentrancyGuard {
  error TimeLock__ProposalAlreadyExecuted();
  error TimeLock__PropossalCancelled();
  error TimeLock__InvalidProposal();
  error TimeLock__StillInTimeLock();

  struct QueuedProposal {
      address target;
      uint256 value;
      bytes data;
      uint256 executeAfter;
      bool executed;
      bool cancelled;
  }

  mapping (bytes32 id => QueuedProposal) private queuedProposal;
  uint256 private timeLockPeriod;

  constructor(uint256 _timeLockPeriod) {
    timeLockPeriod = _timeLockPeriod;
  }

  modifier onlyValidProposal(bytes32 id) {
    if (queuedProposal[id].target == address(0)) revert TimeLock__InvalidProposal();
    _;
  }

  function queueProposal(bytes32 id, address _target, uint256 _value, bytes calldata _data) external onlyValidProposal(id) {
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
  }

  function execute(bytes32 id) external onlyValidProposal(id) returns (bool, bytes memory) {
        QueuedProposal storage proposal = queuedProposal[id];

        if (proposal.executed) revert TimeLock__ProposalAlreadyExecuted();

        if (proposal.cancelled) revert TimeLock__PropossalCancelled();
        if (block.timestamp < proposal.executeAfter) revert TimeLock__StillInTimeLock();
        
        proposal.executed = true;

        (bool success, bytes memory data) = proposal.target.call{value: proposal.value}(proposal.data);
        
        return (success, data);
    }
}