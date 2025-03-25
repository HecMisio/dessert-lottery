// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract VRFSubcriptionCreator is Script {
    function run() external {
        createVRFSubcriptionUsingConfig();
    }

    function createVRFSubcriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        address vrfCoordinator = config.vrfCoordinator;
        address account = config.account;
        uint256 subId = createSubscription(account, vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator, address account) public returns (uint256) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.roll(block.number + 1);
        vm.startBroadcast(account);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Created VRF Subscription");
        console.log("VRF Coordinator:", address(vrfCoordinator));
        console.log("Subscription ID:", subId);
        return subId;
    }
}

contract VRFSubcriptionFunder is Script, CodeConstants {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function run() external {
        fundVRFSubscriptionUsingConfig();
    }

    function fundVRFSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        address link = config.link;
        if (config.subscriptionId == 0) {
            console.log("The subscription ID is not set. Creating a new subscription.");
            VRFSubcriptionCreator creator = new VRFSubcriptionCreator();
            (uint256 subId, address vrfCoordinator) = creator.createVRFSubcriptionUsingConfig();
            config.vrfCoordinator = vrfCoordinator;
            config.subscriptionId = subId;
        }
        fundVRFSubscription(config.vrfCoordinator, config.subscriptionId, link, config.account);
    }

    function fundVRFSubscription(address vrfCoordinator, uint256 subscriptionId, address link, address account)
        public
    {
        console.log("Funding VRF subscription on chainId: ", block.chainid);
        console.log("VRF Coordinator:", address(vrfCoordinator));
        console.log("Subscription ID:", subscriptionId);
        console.log("Funding Amount:", FUND_AMOUNT * 100);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast(account);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT * 100);
            vm.stopBroadcast();
        } else {
            console.log("LINK of Account:", LinkTokenInterface(link).balanceOf(account));
            vm.startBroadcast(account);
            LinkTokenInterface(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
            console.log("Rest LINK of Account:", LinkTokenInterface(link).balanceOf(account));
        }
    }
}

contract VRFComsumerManager is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addVRFConsumerUsingConfig(mostRecentlyDeployed);
    }

    function addVRFConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        address vrfCoordinator = config.vrfCoordinator;
        address account = config.account;
        uint256 subscriptionId = config.subscriptionId;
        addVRFConsumer(mostRecentlyDeployed, vrfCoordinator, subscriptionId, account);
    }

    function addVRFConsumer(address contractToAddVrf, address vrfCoordinator, uint256 subscriptionId, address account)
        public
    {
        console.log("Adding VRF Consumer on chainId: ", block.chainid);
        console.log("VRF Coordinator:", address(vrfCoordinator));
        console.log("Subscription ID:", subscriptionId);
        console.log("Account:", account);
        console.log("Contract to add VRF:", contractToAddVrf);
        vm.startBroadcast(account);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subscriptionId, contractToAddVrf);
        vm.stopBroadcast();
        console.log("Added VRF Consumer");
    }
}
