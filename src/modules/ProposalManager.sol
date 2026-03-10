// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ProposalManager {
    // events
    event ProposalCreated(bytes32 id, address proposer);

    struct Proposal {
        address proposer;
        address target;
        uint256 value;
        bytes data;
        uint256 nonce;
        uint256 timestamp;
        bool approved;
        bool cancelled;
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(address => uint256) public nonces;

    function createProposal(address target, uint256 value, bytes calldata data) external returns (bytes32 id) {
        uint256 nonce = nonces[msg.sender]++;

        id = keccak256(abi.encode(msg.sender, target, value, data, nonce));

        proposals[id] = Proposal({
            proposer: msg.sender,
            target: target,
            value: value,
            data: data,
            nonce: nonce,
            timestamp: block.timestamp,
            approved: false,
            cancelled: false
        });
    }
}
