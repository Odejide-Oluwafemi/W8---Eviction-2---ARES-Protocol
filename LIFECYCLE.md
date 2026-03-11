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

- **Snapshot Voting Power**: In Decentralized governance, Voting power is determined by the user's token balance (implemented at the *start* of the voting period using Openeppelin's `getPastVotes` IVotes interface).

- **Approval**: A proposal is considered "Approved" if, at the `endTime`, `forVotes > againstVotes`, and vice versa.

## 3. The TimeLock Mechanism
Approved proposals must be moved to the timelock queue before they can be executed. It is required that Voting must have ended on that particular proposal, and the proposal must have passed the vote count check (`forVote`).
Any user can call `queueProposal`, after which the proposal is assigned an `eta` countdown time (which is `block.timestamp + timelock`). This makes room for voters to "rethink" their decisions.