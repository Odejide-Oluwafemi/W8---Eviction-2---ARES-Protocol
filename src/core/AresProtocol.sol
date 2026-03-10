// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Vault } from "src/core/Vault.sol";

contract AresProtocol {
  Vault immutable vault;

  constructor() {
    vault = new Vault();
  }

  function getVaultAddress() external view returns (address) {
    return address(vault);
  }
}
