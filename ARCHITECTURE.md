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

