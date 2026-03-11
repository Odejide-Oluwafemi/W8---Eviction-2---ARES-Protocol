// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IAresProtocol.sol";
import "../modules/Voting.sol";
import "../modules/RewardDistributor.sol";

contract AresProtocol is IAresProtocol, Voting, RewardDistributor {
    
    uint256 public timelock = 2 days;
    uint256 public gracePeriod = 7 days;
    uint256 public maxTreasuryWithdraw = 1000000 * 10 ** 18;

    constructor(address _token, address _treasury, address _admin) 
        Voting("AresProtocol", "1.0") 
    {
        governanceToken = _token;
        treasury = _treasury;
        admin = _admin;
    }

    function createProposal(
        address target,
        uint256 amount,
        bytes calldata data,
        string calldata desc
    ) external override returns (uint256) {
        require(amount <= maxTreasuryWithdraw, "Amount too high");

        uint256 id = _createProposal(msg.sender, target, amount, data, desc);
        return id;
    }

    function vote(uint256 proposalId, bool support) external override {
        _vote(proposalId, msg.sender, support);
    }

    function voteBySig(
        uint256 proposalId,
        bool support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        _voteBySig(proposalId, support, v, r, s);
    }

    function queueProposal(uint256 proposalId) external override {
        IAresProtocol.Proposal storage p = proposals[proposalId];
        require(block.timestamp > p.endTime, "Voting not ended");
        require(p.forVotes > p.againstVotes, "Proposal failed");
        require(!p.queued, "Already queued");

        p.queued = true;
        p.eta = block.timestamp + timelock;
    }

    function executeProposal(uint256 proposalId) external override noReentrant {
        IAresProtocol.Proposal storage p = proposals[proposalId];

        require(p.queued, "Not queued");
        require(block.timestamp >= p.eta, "Timelock active");
        require(block.timestamp <= p.eta + gracePeriod, "Proposal stale");
        require(!p.executed, "Already executed");
        require(!p.canceled, "Canceled");
        require(keccak256(p.data) == p.dataHash, "Hash mismatch");

        p.executed = true;

        (bool success, ) = p.target.call{value: 0}(p.data);
        require(success, "Execution failed");
    }

    function cancelProposal(uint256 proposalId) external override {
        IAresProtocol.Proposal storage p = proposals[proposalId];
        require(msg.sender == p.proposer, "Not proposer");
        require(!p.executed, "Already executed");
        require(!p.canceled, "Already canceled");

        p.canceled = true;
    }

    function setRewardRoot(bytes32 root, uint256 amount) external override {
        _setRewardRoot(root, amount);
    }

    function claimReward(
        uint256 roundId,
        address user,
        uint256 amount,
        bytes32[] calldata proof
    ) external override {
        _claimReward(roundId, user, amount, proof);
    }

    function setAdmin(address newAdmin) external {
        require(msg.sender == admin, "Not admin");
        admin = newAdmin;
    }

    function setTreasury(address newTreasury) external {
        require(msg.sender == admin, "Not admin");
        treasury = newTreasury;
    }
    
    receive() external payable {}

    function domainSeparator() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function getProposal(
        uint256 id
    ) external view override returns (Proposal memory) {
        return proposals[id];
    }

    function hasVoted(
        uint256 proposalId,
        address voter
    ) external view override returns (bool) {
        return voterHasVoted[proposalId][voter];
    }
}
