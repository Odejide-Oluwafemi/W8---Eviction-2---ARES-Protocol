// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AresToken} from "src/core/AresToken.sol";

contract Vault is ReentrancyGuard {
  AresToken immutable token;

  mapping(address => uint) private balances;

  constructor() {
    token = new AresToken();
  }

  function deposit(uint amount) external {
    bool success = token.transferFrom(msg.sender, address(this), amount);
    require(success);
    
    balances[msg.sender] += amount;
  }

  function withdrawTo(address from, address to, uint amount) external {
    balances[from] -= amount;
    balances[to] += amount;
    bool success = token.transfer(to, amount);
    require(success);
  }
}