// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/modules/RewardDistributor.sol";

contract RewardDistributorTest is Test, RewardDistributor {
    function transfer(address, uint256) external pure returns (bool) {
        return true;
    }

    function setUp() public {
        admin = address(1);
        treasury = address(this);
    }

    function test_CoreFlow() public {
        bytes32 leaf = keccak256(abi.encodePacked(address(2), uint256(100)));
        
        vm.prank(address(1));
        _setRewardRoot(leaf, 100);
        
        _claimReward(1, address(2), 100, new bytes32[](0));
        assertTrue(hasClaimed[1][address(2)]);
    }
}
