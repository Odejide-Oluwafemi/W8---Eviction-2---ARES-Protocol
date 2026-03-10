// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAresProtocol {
    struct Proposal {
        uint256 id;
        address proposer;
        address target;
        uint256 amount;
        bytes data;
        bytes32 dataHash; // Added for calldata tamper test
        string description;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        bool canceled;
        uint256 eta;
        bool queued;
    }

    struct RewardRound {
        uint256 id;
        bytes32 merkleRoot;
        uint256 totalAmount;
        uint256 claimedAmount;
        bool active;
    }

    function createProposal(address target, uint256 amount, bytes calldata data, string calldata desc) external returns (uint256);
    function vote(uint256 proposalId, bool support) external;
    function voteBySig(uint256 proposalId, bool support, uint8 v, bytes32 r, bytes32 s) external;
    function queueProposal(uint256 proposalId) external;
    function executeProposal(uint256 proposalId) external;
    function setRewardRoot(bytes32 root, uint256 amount) external;
    function claimReward(uint256 roundId, address user, uint256 amount, bytes32[] calldata proof) external;
    
    function getProposal(uint256 id) external view returns (Proposal memory);
    function hasVoted(uint256 proposalId, address voter) external view returns (bool);
}
