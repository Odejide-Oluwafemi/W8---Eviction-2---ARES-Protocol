// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AresToken} from "src/core/AresToken.sol";

contract AresProtocol {
    AresToken immutable token;

    constructor(address aresToken) {
        token = AresToken(aresToken);
    }
}
