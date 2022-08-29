// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PartyPanda.sol";

contract PartyPandaScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        PartyPanda token = new PartyPanda();

        vm.stopBroadcast();
    }
}
