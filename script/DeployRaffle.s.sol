// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {VRFSubcriptionCreator, VRFSubcriptionFunder, VRFComsumerManager} from "./Integrations.s.sol";

contract DeployRaffle is Script {
    function run() external {
        deployRaffle();
    }

    function deployRaffle() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            // create VRF subscription
            VRFSubcriptionCreator creator = new VRFSubcriptionCreator();
            config.subscriptionId = creator.createSubscription(config.vrfCoordinator, config.account);
            helperConfig.setConfig(block.chainid, config);
            // fund subscription
            VRFSubcriptionFunder funder = new VRFSubcriptionFunder();
            funder.fundVRFSubscription(config.vrfCoordinator, config.subscriptionId, config.link, config.account);
        }

        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.callbackGasLimit,
            config.subscriptionId
        );
        vm.stopBroadcast();

        // add subscription consumer
        VRFComsumerManager consumerManager = new VRFComsumerManager();
        consumerManager.addVRFConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId, config.account);

        return (raffle, helperConfig);
    }
}
