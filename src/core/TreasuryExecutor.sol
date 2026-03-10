// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Governor } from "@openzeppelin/contracts/governance/Governor.sol";

// create -> commit -> approve -> queue -> execute
contract TreasuryExecutor is Governor {
  constructor() Governor("ARES Protocol") {

  }

  uint public quorumRequired;
  mapping (uint proposalId => mapping (address account => bool proposed)) public hasVotedOnProposal;
  mapping (uint proposalId => uint quorums) proposalQuorums;

    function clock() public view override returns (uint48) {}

    function CLOCK_MODE() public view override returns (string memory) {}

    function COUNTING_MODE() external view override returns (string memory) {}

    function votingDelay() public view override returns (uint256) {}

    function votingPeriod() public view override returns (uint256) {}

    function quorum(uint256 timepoint) public view override returns (uint256) {}

    function hasVoted(
        uint256 proposalId,
        address account
    ) external view override returns (bool) {
      return hasVotedOnProposal[proposalId][account];
    }

    function _quorumReached(
        uint256 proposalId
    ) internal view virtual override returns (bool) {
      return proposalQuorums[proposalId] >= quorumRequired;
    }

    function _voteSucceeded(
        uint256 proposalId
    ) internal view virtual override returns (bool) {}

    function _getVotes(
        address account,
        uint256 timepoint,
        bytes memory params
    ) internal view virtual override returns (uint256) {}

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 totalWeight,
        bytes memory params
    ) internal virtual override returns (uint256) {}
}
