# Ares Protocol Lifecycle

Proposal Lifecycle from creation to Execution or Cancellation.


## 1. Proposal Creation
- **Eligibility**: The proposer must be holding at least `minTokensToPropose` tokrns before a proposal can be made.

- **Withdraw Limit**: If the proposal has to do with a treasury transfer, then the `amount` must not exceed `maxTreasuryWithdraw`.

- **Initialization**: Upon calling `createProposal`, the system:
    - Assigns a unique `proposalId`.
    - Captures the keccak-256 `dataHash` of the execution payload calldata.
    - Sets the `endTime` (current time + `votingPeriod`).

## 2. Approval (Voting)
Once a proposal has been created, users can start voting on it.
- **Voting Timeframe**: Users can cast votes (For/Against) until the `endTime` is reached.

- **Snapshot Power**: Voting power is determined by the user's token balance at the *start* of the voting period (using Openeppelin's `getPastVotes`).

- **Approva;**: A proposal is considered "Approved" if, at the `endTime`, `forVotes > againstVotes`, and vice versa.
