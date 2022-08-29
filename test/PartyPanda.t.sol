// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PartyPanda.sol";

contract PartyPandaTest is Test {
    PartyPanda public token;

    address holder = address(1);

    function setUp() public {
        token = new PartyPanda();
    }

    function testMetadata() public {
        assertEq(token.name(), "Party Panda 2.0");
        assertEq(token.symbol(), "PP2");
    }

    function testOwner() public {
        assertEq(token.owner(), 0x13ebd3443fa5575F0Eb173e323D8419F7452CfB1);
    }

    function testSupportsERC4883() public {
        assertEq(token.supportsInterface(type(IERC4883).interfaceId), true);
    }

    function testNoMint() public {
        assertEq(token.totalSupply(), 0);
    }

    function testMint() public {
        vm.prank(holder);
        token.mint();

        assertEq(token.balanceOf(holder), 1);
        assertEq(token.ownerOf(1), holder);
        assertEq(token.totalSupply(), 1);
    }

    function testMintWithinCap() public {
        vm.startPrank(holder);
        for (uint256 index = 0; index < token.supplyCap(); index++) {
            token.mint();
        }
        vm.stopPrank();

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(holder), token.supplyCap());
        assertEq(token.ownerOf(token.supplyCap()), holder);
    }

    function testMintOverCap() public {
        vm.startPrank(holder);
        for (uint256 index = 0; index < token.supplyCap(); index++) {
            token.mint();
        }

        vm.expectRevert(PartyPanda.SupplyCapReached.selector);
        token.mint();
        vm.stopPrank();

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(holder), token.supplyCap());
        assertEq(token.ownerOf(token.supplyCap()), holder);
    }

    function testFailTokenUriOfUnminted() public view {
        token.tokenURI(0);
    }
}
