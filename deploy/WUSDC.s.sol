// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/Script.sol";
import {WUSDC} from "src/WUSDC.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        WUSDC wusdc = new WUSDC();

        vm.stopBroadcast();
    }
}