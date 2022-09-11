// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PartyPanda2.sol";

contract PartyPanda2Script is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        new PartyPanda2();

        vm.stopBroadcast();
    }
}
