// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {TimeLock} from "src/modules/TimeLock.sol";

contract ProposalManager is ReentrancyGuard {
    // Errors
    error ProposalManager__DuplicateProposal();
    error ProposalManager__InvalidSigner();
    error ProposalManager__CannotCommitOwnProposal();
    error ProposalManager__AlreadyApproved();
    error ProposalManager__AlreadyCancelled();

    // Events
    event ProposalCreated(bytes32 id, address proposer);

    bytes public constant TRANSFER_ACTION = abi.encodeWithSignature("transfer(address,address,uint256)");
    bytes public constant CALL_ACTION = abi.encodeWithSignature("call(address,bytes)");
    bytes public constant UPGRADE_ACTION = abi.encodeWithSignature("upgrade(address)");

    address[] public signers;
    uint8 public quoremCount;
    TimeLock immutable timeLock;

    struct Proposal {
        address proposer;
        address target;
        uint256 value;
        bytes data;
        uint256 nonce;
        bool cancelled;
        ProposalStatus status;
        uint8 approvalCount;
    }

    enum ProposalStatus {
        Draft, // Newly Created
        Commit, // Quorum Achieved
        Queued, // In TimeLock Period
        ReadyForExecution, // Can be Executed By Proposer
        Executed // Has been executed
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(address => uint256) public nonces;
    mapping(address signer => bool valid) private isValidSigner;
    mapping(bytes32 proposalId => mapping (address signer => bool cancel)) private proposalCancelledBy;
    mapping(bytes32 proposalId => mapping (address signer => bool cancel)) private proposalApprovedBy;

    constructor(address[] memory _signers, uint8 _quoremCount, address _timelock) {
        quoremCount = _quoremCount;
        timeLock = TimeLock(_timelock);

        for (uint256 i; i < _signers.length; i++) {
            signers[i] = _signers[i];
            isValidSigner[_signers[i]] = true;
        }
    }

    // Modifiers
    modifier onlyValidSigner() {
        if (!isValidSigner[msg.sender]) revert ProposalManager__InvalidSigner();

        _;
    }

    function createProposal(address target, uint256 value, bytes calldata data)
        external
        onlyValidSigner
        returns (bytes32 id)
    {
        uint256 nonce = nonces[msg.sender]++;

        id = keccak256(abi.encode(msg.sender, target, value, data, nonce));

        if (proposals[id].proposer != address(0)) revert ProposalManager__DuplicateProposal();

        proposals[id] = Proposal({
            proposer: msg.sender,
            target: target,
            value: value,
            data: data,
            nonce: nonce,
            cancelled: false,
            status: ProposalStatus.Draft,
            approvalCount: 0
        });
    }

    function approveProposal(bytes32 id) external onlyValidSigner {
        Proposal storage proposal = proposals[id];

        if (msg.sender == proposal.proposer) revert ProposalManager__CannotCommitOwnProposal();
        if (proposalApprovedBy[id][msg.sender]) revert ProposalManager__AlreadyApproved();

        proposalApprovedBy[id][msg.sender] = true;
        proposalCancelledBy[id][msg.sender] = false;

        proposal.approvalCount = proposal.approvalCount + 1;

        if (proposal.approvalCount >= quoremCount) {
          proposal.status = ProposalStatus.Queued;
          timeLock.queueProposal(id, proposal.target, proposal.value, proposal.data);
        }
    }

    function cancelProposal(bytes32 id) external onlyValidSigner {
      Proposal memory proposal = proposals[id];
      if (proposalCancelledBy[id][msg.sender]) revert ProposalManager__AlreadyCancelled();

      proposalCancelledBy[id][msg.sender] = true;
      proposalApprovedBy[id][msg.sender] = false;

      proposal.approvalCount = proposal.approvalCount - 1;
    }

    function getProposalById(bytes32 id) external view returns (Proposal memory) {
        return proposals[id];
    }
}
