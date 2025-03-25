# Provably Random Raffle Contracts

## About

This project implements a provably random smart contract lottery using Chainlink VRF and Chainlink Automation. The goal is to create a decentralized raffle system where users can participate by purchasing tickets, and a winner is selected programmatically in a fair and transparent manner.

This is a project for learning. You can find the corresponding courses <a href="https://updraft.cyfrin.io/courses/foundry">here</a>.

---

## Features

1. **User Participation**:
   - Users can enter the raffle by paying a ticket fee.
   - The ticket fees collected form the prize pool for the winner.

2. **Automated Winner Selection**:
   - The lottery automatically selects a winner after a predefined interval.
   - The winner is chosen using Chainlink VRF for provable randomness.

3. **Chainlink VRF Integration**:
   - Ensures the randomness used for selecting the winner is verifiable and tamper-proof.

4. **Chainlink Automation**:
   - Automates the process of triggering the lottery draw at regular intervals.

---

## How It Works

1. **Entering the Raffle**:
   - Users call the `enterRaffle` function and pay the required entrance fee.
   - Their address is added to the list of participants.

2. **Triggering the Lottery**:
   - Chainlink Automation checks if the conditions for the lottery draw are met (e.g., time interval passed, raffle is open, etc.).
   - If conditions are met, the `performUpkeep` function is called to start the winner selection process.

3. **Winner Selection**:
   - Chainlink VRF generates a random number.
   - The random number is used to select a winner from the list of participants.
   - The winner receives the entire prize pool.

---

## Prerequisites

- **Foundry**: Install Foundry for testing and deployment.
- **Chainlink Tools**: Familiarity with Chainlink VRF and Automation.

---

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/your-username/dessert-lottery.git
    cd dessert-lottery
    ```

2. Install dependencies:

    ```bash
    forge install
    ```

3. Compile the smart contracts:

    ```bash
    forge build
    ```

4. Run tests to ensure everything is working:

    ```bash
    forge test
    ```

---

## Deployment

1. Configure environment variables:

    Create a `.env` file and add the following:

    ```env
    SCAN_API_KEY=your_api_key
    RPC_URL=your_rpc_url
    ```

2. Deployment Configuration

    The project uses a HelperConfig contract to manage network-specific configurations. Update the configuration in script/HelperConfig.s.sol for your target network.

    Example Configuration:

    ```Solidity
    NetworkConfig memory localConfig = NetworkConfig({
        entranceFee: 0.01 ether,
        interval: 300, // 5 minutes
        vrfCoordinator: <VRF_COORDINATOR_ADDRESS>,
        gasLane: <GAS_LANE_KEY>,
        callbackGasLimit: 500000,
        subscriptionId: <SUBSCRIPTION_ID>,
        link: <LINK_TOKEN_ADDRESS>,
        account: <DEPLOYER_ADDRESS>
    });
    ```

3. Deploy the contract:

    ```bash
    forge script script/DeployRaffle.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
    ```

4. Verify the contract (optional):

    ```bash
    forge verify-contract --chain-id your_chain_id --etherscan-api-key your_api_key
    ```

---

## License

This project is licensed under the MIT License.
