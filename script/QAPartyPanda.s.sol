// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PartyPanda.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract QAPartyPandaScript is Script, ERC721Holder {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        PartyPanda token = new PartyPanda();
        token.mint{value: token.price()}();
        console.log(token.tokenURI(1));

        vm.stopBroadcast();
    }
}
