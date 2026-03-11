# Ares Protocol

The ARES Protocol is a treasury and reward distribution system that is designed to provide a secure, modular, and governance-controlled infrastructure for managing large-scale digital assets. The protocol manages treasury funds exceeding hundreds of millions of dollars, and has been designed from scratch due to a belief that existing vault designs are flawed and insecure. The design implemented is Modular in nature with core logics properly split into thei rrespective files.

## 1. System Architecture

Ares Protocol being a governance and reward distribution system allows token holders to create proposals, vote on them, and execute them after a mandatory timelock. It also features a Merkle-based reward distribution mechanism.

### Key Components:
- **AresProtocol (Core)**: The main Governance contract which serves as the entry point. It manages the timelock, grace period, and execution of approved proposals.
- **Voting**: Manages the proposal lifecycle (creation and voting). Supports both direct on-chain voting and gasless voting via EIP-712 signatures.
- **RewardDistributor Module**: An abstract module for claiming rewards using Merkle proofs. It interacts with an external treasury to fulfill payments.
- **HelperFunctions**: A quick library for Merkle proof verification and ECDSA signer recovery actions.

## 2. Module Separation

The system follows a modular design to separate concerns and improve maintainability:

- **src/core/AresProtocol.sol**: Integrates `Voting` and `RewardDistributor`. It defines the specific governance parameters (timelock, grace period, max withdraw) and the final `executeProposal` logic.
- **src/modules/Voting.sol**: Encapsulates all voting logic, including proposal state management (`proposals` mapping), balance checks, and signature verification.
- **src/modules/RewardDistributor.sol**: Focuses exclusively on rewards management and Merkle proof validation.
- **src/interfaces/IAresProtocol.sol**: Centralized definitions for structs (`Proposal`, `RewardRound`) and external interfaces to ensure consistency across modules.

## 3. System Design

The design fetures:
- **Separation of Concerns**: Every layer of logic implemented here, ranging from the Governance logic, transaction execution, to the distribution mechanisms are implemented in separate contracts to reduce complexity and avoid monolith. This helps to easily make upgrades to any part of the code and identify bugs easier.

- **Cryptographic-Secured Approvals**: All treasury actions require structured signatures to ensure that only authorized governance people can approve proposals.

- **Timelock Mechanism**: This makes sure that the governance people can recheck their decisions by creating a little time frame before an approved proposal is finally executed by the contract. This gives more room to react to invalid or suspicious proposals by allowing them to withdraw their vote.

- **Merkle Proof for Large Distribution**: The RewardDistributor uses a Merkle tree verification method to enable gas-efficient token distribution to thousands of participants (rather than using an array and looping through it).

## 4. Security
For security, the following were implemented:

- **Reentrancy Guard**: A modifier named `noReentrant` is used to prevent a reentrancy attack (where users can recall a function before its first call finishes and state is properly updated). It uses a `locked` variable to prevent multiple calls to the function.

- **Execution Guard**: Every proposal must wait an extra amount of time (`eta`) after voting ends before it can be finally executed. It also has a `gracePeriod` where, if not executed after then, it becomes "stale" and can never be executed again.

- **Proposal Integrity**: Proposals have a keccak256 `dataHash`, which is used to assure that the calldata has not been tampered with since the proposal was created.

- **Access Control**: 
  - Only the `admin` can set reward roots.
  - Only users with a minimum token balance can create proposals.
  - Only users who haven't voted can cast a vote for a specific proposal.

- **Merkle Proofs**: Reward claims are verified against a root stored by the admin, ensuring users can only claim the exact amount allocated to them.

## 4. Trust Assumptions

The Trust Assumptions required for this contract to function as expected are:

- **Admin Honesty**: The `admin` is trusted to set correct Merkle roots and manage the `treasury` and `admin` addresses. If the admin is compromised, reward funds can be misdirected.

- **Governance Token Integrity**: The system assumes the ERC20 `governanceToken` correctly implements `balanceOf` and `getPastVotes(address,uint256)`. Malicious tokens could break the voting mechanism in one way or the other.

- **Treasury Liquidity**: The protocol assumes the `treasury` contract (or address) has sufficient balance to satisfy `transfer` calls for both reward claims and proposal executions (although there is a `maxTreasuryWithdraw` to ensure no proposal can be created to withdraw more than this amount)

- **Oracle/Data Feed (Off-chain)**: The Merkle Root that is passed in, is generated offchain and it is assumed to have been done correctly and the off-chain system generating it is also assumed to be accurate and secure.