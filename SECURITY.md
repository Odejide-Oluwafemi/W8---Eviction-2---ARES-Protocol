# Ares Protocol Security

How attacks like (Reentrancy, Signature replay, Double claim, Unauthorized execution, Timelock bypass, Governance griefing) are mitigated:


## 1. Mitigations

| Attack Vector | | Mitigation Strategy |
| :--- | :--- | :--- |
| **Reentrancy** | |`noReentrant` modifier on `executeProposal`; state variable `executed` is updated before the external `call`. 
| **Signature Replay** || Uses **EIP-712** typed data (domain separator includes `chainId` and contract address). `voterHasVoted` mapping ensures a specific signature for a `proposalId` cannot be reused by the same signer. |
| **Double Claim** | |`hasClaimed[roundId][user]` mapping prevents users from claiming multiple times within the same reward round. |
| **Unauthorized Execution** || `executeProposal` requires `p.queued == true`. Only proposals that passed the vote and the 2-day timelock can be queued. |
| **Timelock Bypass**| | Strict enforcement of `block.timestamp Must be >= p.eta` in the execution logic. |
| **Governance Griefing** || `minTokensToPropose` prevents a low-stake spam. |


## 2. How attackers might try to break the protocol

### External Call Reentrancy
The `executeProposal` function performs arbitrary external calls to a `target` with provided `data`. This is could be an attack point for re-entering the protocol or draining funds.

