// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract AresProtocol is Governor, GovernorVotes {
  constructor(IVotes _token) Governor("Ares Protocol") GovernorVotes(_token){

  }
    function clock() public view override(Governor, GovernorVotes) returns (uint48) {}

    function CLOCK_MODE() public view override(Governor, GovernorVotes) returns (string memory) {}

    function COUNTING_MODE() external view override returns (string memory) {}

    function votingDelay() public view override returns (uint256) {}

    function votingPeriod() public view override returns (uint256) {}

    function quorum(uint256 timepoint) public view override returns (uint256) {}

    function hasVoted(
        uint256 proposalId,
        address account
    ) external view override returns (bool) {}

    function _quorumReached(
        uint256 proposalId
    ) internal view virtual override returns (bool) {}

    function _voteSucceeded(
        uint256 proposalId
    ) internal view virtual override returns (bool) {}

    function _getVotes(
        address account,
        uint256 timepoint,
        bytes memory params
    ) internal view virtual override(Governor, GovernorVotes) returns (uint256) {}

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 totalWeight,
        bytes memory params
    ) internal virtual override returns (uint256) {}
}