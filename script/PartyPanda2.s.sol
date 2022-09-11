// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PartyPanda2.sol";
import "../src/NounsGlasses.sol";
import "../src/Crown.sol";
import "../src/Box.sol";

contract PartyPanda2Script is Script {
    function setUp() public {}

    function run() public {
        //uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.broadcast();

        PartyPanda2 token = new PartyPanda2();
        Box background = new Box();
        NounsGlasses glasses = new NounsGlasses();
        Crown crown = new Crown();

        vm.stopBroadcast();
    }
}
