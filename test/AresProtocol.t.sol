// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/core/AresProtocol.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    function setBalance(address u, uint256 a) public { balanceOf[u] = a; }
    function getPastVotes(address, uint256) public pure returns (uint256) { return 1000; }
}

contract MaliciousTarget {
    AresProtocol protocol;
    uint256 propId;
    bool shouldReenter;

    function setParams(address p, uint256 id) public {
        protocol = AresProtocol(payable(p));
        propId = id;
    }

   
    function doSomething() public {
        if (shouldReenter) {
            shouldReenter = false; 
            protocol.executeProposal(propId);
        }
    }

    function enableReentry() public {
        shouldReenter = true;
    }

    receive() external payable {}
    fallback() external payable {}
}

contract AresProtocolTest is Test {
    AresProtocol protocol;
    MockToken token;
    address admin = address(0xAD);
    address treasury = address(0x456);
    address user = address(0x123);
    uint256 userPrivKey = 0x1234;

    function setUp() public {
        token = new MockToken();
        protocol = new AresProtocol(address(token), treasury, admin);
        token.setBalance(user, 1000);
        token.setBalance(vm.addr(userPrivKey), 1000);
        
        // Give treasury some ETH for rewards (though our mock treasury just returns true)
        vm.deal(treasury, 100 ether);
    }

    // --- Functional Tests ---

    function test_ProposalLifecycle() public {
        vm.prank(user);
        uint256 id = protocol.createProposal(address(0), 0, "", "desc");
        
        vm.prank(user);
        protocol.vote(id, true);
        
        vm.warp(block.timestamp + 4 days);
        protocol.queueProposal(id);
        
        vm.warp(block.timestamp + 3 days);
        protocol.executeProposal(id);
        
        assertTrue(protocol.getProposal(id).executed);
    }


}