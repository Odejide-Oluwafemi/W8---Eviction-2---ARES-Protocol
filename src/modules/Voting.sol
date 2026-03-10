// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IAresProtocol.sol";
import "../libraries/HelperFunctions.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// Module for handling voting logic
abstract contract Voting is EIP712 {
    mapping(uint256 => IAresProtocol.Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public voterHasVoted;
    uint256 public proposalCount;
    
    uint256 public votingPeriod = 3 days;
    uint256 public minTokensToPropose = 100;
    address public governanceToken;
    
    bytes32 public constant VOTE_TYPEHASH = keccak256("Vote(uint256 proposalId,bool support)");

    constructor(string memory name, string memory version) EIP712(name, version) {}

    bool internal locked;
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function _createProposal(
        address proposer,
        address target,
        uint256 amount,
        bytes calldata data,
        string calldata desc
    ) internal returns (uint256) {
        require(_balanceOf(proposer) >= minTokensToPropose, "Not enough tokens");
        
        proposalCount = proposalCount + 1;
        uint256 id = proposalCount;
        
        proposals[id] = IAresProtocol.Proposal({
            id: id,
            proposer: proposer,
            target: target,
            amount: amount,
            data: data,
            dataHash: keccak256(data),
            description: desc,
            endTime: block.timestamp + votingPeriod,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            canceled: false,
            eta: 0,
            queued: false
        });
        
        return id;
    }

    function _vote(uint256 proposalId, address voter, bool support) internal {
        IAresProtocol.Proposal storage p = proposals[proposalId];
        
        require(block.timestamp < p.endTime, "Voting ended");
        require(!p.executed, "Already executed");
        require(!voterHasVoted[proposalId][voter], "Already voted");
        
        uint256 votes = _getPastVotes(voter, p.endTime - votingPeriod);
        require(votes > 0, "No tokens");
        
        voterHasVoted[proposalId][voter] = true;
        
        if (support) {
            p.forVotes = p.forVotes + votes;
        } else {
            p.againstVotes = p.againstVotes + votes;
        }
    }

    function _voteBySig(
        uint256 proposalId,
        bool support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        bytes32 structHash = keccak256(abi.encode(VOTE_TYPEHASH, proposalId, support));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        
        _vote(proposalId, signer, support);
    }

    function _getPastVotes(address account, uint256 blockTimestamp) internal view returns (uint256) {
        (bool success, bytes memory result) = governanceToken.staticcall(
            abi.encodeWithSignature("getPastVotes(address,uint256)", account, blockTimestamp)
        );
        if (success) {
            return abi.decode(result, (uint256));
        }
        return 0;
    }

    function _balanceOf(address account) internal view returns (uint256) {
        (bool success, bytes memory result) = governanceToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", account)
        );
        if (success) {
            return abi.decode(result, (uint256));
        }
        return 0;
    }
}
