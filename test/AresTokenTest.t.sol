pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AresToken} from "src/core/AresToken.sol";

contract TokenTest is Test {
    AresToken token;

    function setUp() public {
        token = new AresToken();
    }

    function testMint() public {
        uint256 before = token.balanceOf(address(this));
        token.mint(address(this), 100);
        uint256 after_ = token.balanceOf(address(this));
        assertEq(after_ - before, 100);
    }
}
