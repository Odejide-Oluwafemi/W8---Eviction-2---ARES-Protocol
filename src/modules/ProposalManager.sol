// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ProposalManager {
    // Errors
    error ProposalManager__CannotExecuteTransaction();
    error ProposalManager__DuplicateProposal();
    error ProposalManager__InvalidSigner();
    error ProposalManager__CannotCommitOwnProposal();

    // Events
    event ProposalCreated(bytes32 id, address proposer);

    bytes public constant TRANSFER_ACTION = abi.encodeWithSignature("transfer(address,address,uint256)");
    bytes public constant CALL_ACTION = abi.encodeWithSignature("call(address,bytes)");
    bytes public constant UPGRADE_ACTION = abi.encodeWithSignature("upgrade(address)");

    address[] public signers;
    uint8 public quoremCount;

    struct Proposal {
        address proposer;
        address target;
        uint256 value;
        bytes data;
        uint256 nonce;
        uint256 timestamp;
        bool approved;
        bool cancelled;
        ProposalStatus status;
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

    constructor(address[] memory _signers, uint8 _quoremCount) {
        quoremCount = _quoremCount;

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
            timestamp: block.timestamp,
            approved: false,
            cancelled: false,
            status: ProposalStatus.Draft
        });
    }

    function commitProposal(bytes32 id) external onlyValidSigner {
        Proposal storage proposal = proposals[id];
        if (msg.sender == proposal.proposer) revert ProposalManager__CannotCommitOwnProposal();
        proposal.status = ProposalStatus.Queued;
    }

    function execute(Proposal memory proposal) external returns (bool, bytes memory) {
        if (proposal.status == ProposalStatus.ReadyForExecution) revert ProposalManager__CannotExecuteTransaction();
        (bool success, bytes memory data) = proposal.target.call{value: proposal.value}(proposal.data);

        return (success, data);
    }

    function getProposalById(bytes32 id) external view returns (Proposal memory) {
        return proposals[id];
    }
}
