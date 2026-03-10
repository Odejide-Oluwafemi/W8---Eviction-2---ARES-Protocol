// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IAresProtocol.sol";
import "../libraries/HelperFunctions.sol";

abstract contract RewardDistributor {
    mapping(uint256 => IAresProtocol.RewardRound) public rewardRounds;
    mapping(uint256 => mapping(address => bool)) public hasClaimed;
    uint256 public rewardRoundCount;
    
    address public treasury;
    address public admin;

    function _setRewardRoot(
        bytes32 root,
        uint256 amount
    ) internal returns (uint256) {
        require(msg.sender == admin, "Not admin");
        require(root != bytes32(0), "Zero root");
        
        rewardRoundCount = rewardRoundCount + 1;
        uint256 id = rewardRoundCount;
        
        rewardRounds[id] = IAresProtocol.RewardRound({
            id: id,
            merkleRoot: root,
            totalAmount: amount,
            claimedAmount: 0,
            active: true
        });
        
        return id;
    }

    function _claimReward(
        uint256 roundId,
        address user,
        uint256 amount,
        bytes32[] calldata proof
    ) internal {
        require(rewardRounds[roundId].active, "Round not active");
        require(!hasClaimed[roundId][user], "Already claimed");
        
        bytes32 leaf = keccak256(abi.encodePacked(user, amount));
        require(
            HelperFunctions.verifyMerkleProof(proof, rewardRounds[roundId].merkleRoot, leaf),
            "Invalid proof"
        );
        
        uint256 remaining = rewardRounds[roundId].totalAmount - rewardRounds[roundId].claimedAmount;
        require(amount <= remaining, "Not enough funds");
        
        hasClaimed[roundId][user] = true;
        rewardRounds[roundId].claimedAmount = rewardRounds[roundId].claimedAmount + amount;
        

        (bool success, ) = treasury.call(
            abi.encodeWithSignature("transfer(address,uint256)", user, amount)
        );
        require(success, "Transfer failed");
    }
}