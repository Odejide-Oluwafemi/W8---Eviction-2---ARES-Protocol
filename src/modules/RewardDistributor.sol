// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RewardDistributor {
  // Errors
  error RewardDistributor__YouCannotCallThis();
  error RewardDistributor__AlreadyClaimed();
  error RewardDistributor__InvalidProof();
  error RewardDistributor__Unauthorized();
  
  // Events
    event MerkleRootUpdated(bytes32 newRoot);
    event RewardClaimed(address indexed account, uint256 amount);

      mapping(bytes32 => bool) public hasClaimed;

  bytes32 public merkleRoot;
  address public admin;

   constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
        admin = msg.sender;
    }

        function updateMerkleRoot(bytes32 _newRoot) external {
        if (msg.sender != admin) revert RewardDistributor__YouCannotCallThis();
        merkleRoot = _newRoot;
        emit MerkleRootUpdated(_newRoot);
    }

     function claim(uint256 amount, bytes32[] calldata proof) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));

        if (hasClaimed[leaf]) revert RewardDistributor__AlreadyClaimed();

        if (!_verify(proof, leaf)) revert RewardDistributor__InvalidProof();

        hasClaimed[leaf] = true;

        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert RewardDistributor__Unauthorized();

        emit RewardClaimed(msg.sender, amount);
    }

    function _verify(bytes32[] memory proof, bytes32 leaf) internal view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == merkleRoot;
    }

}