# Ares Protocol Lifecycle

Proposal Lifecycle from creation to Execution or Cancellation.


## 1. Proposal Creation
- **Eligibility**: The proposer must be holding at least `minTokensToPropose` tokrns before a proposal can be made.

- **Withdraw Limit**: If the proposal has to do with a treasury transfer, then the `amount` must not exceed `maxTreasuryWithdraw`.

- **Initialization**: Upon calling `createProposal`, the system:
    - Assigns a unique `proposalId`.
    - Captures the keccak-256 `dataHash` of the execution payload calldata.
    - Sets the `endTime` (current time + `votingPeriod`).

