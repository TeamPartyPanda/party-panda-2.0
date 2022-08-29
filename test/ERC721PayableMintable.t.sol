// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC721PayableMintable} from "../src/ERC721PayableMintable.sol";
import {MockERC721PayableMintable} from "./mocks/MockERC721PayableMintable.sol";

contract ERC721PayableMintableTest is Test {
    MockERC721PayableMintable token;

    uint256 constant PAYMENT = 0.001 ether;

    address constant OTHER_ADDRESS = address(1);
    address constant OWNER = address(2);
    address constant PAYMENT_RECIPIENT = address(3);
    address constant TOKEN_HOLDER = address(4);

    function setUp() public {
        token = new MockERC721PayableMintable(OWNER);
    }

    function testMetadata() public {
        assertEq(token.name(), token.NAME());
        assertEq(token.symbol(), token.SYMBOL());
    }

    /// Mint

    function testMint(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        assertEq(address(token).balance, amount);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(1), address(this));
    }

    function testMintWithInsufficientPayment(uint96 amount) public {
        vm.assume(amount < PAYMENT);

        vm.expectRevert(ERC721PayableMintable.InsufficientPayment.selector);
        token.mint{value: amount}();

        assertEq(address(token).balance, 0 ether);

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testMintWithinCap() public {
        for (uint256 index = 0; index < token.supplyCap(); index++) {
            token.mint{value: PAYMENT}();
        }

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap());
    }

    function testMintOverCap() public {
        for (uint256 index = 0; index < token.supplyCap(); index++) {
            token.mint{value: PAYMENT}();
        }

        vm.expectRevert(ERC721PayableMintable.SupplyCapReached.selector);
        token.mint{value: PAYMENT}();

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap());
    }

    /// Payment

    function testWithdraw(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        vm.prank(OWNER);
        token.withdraw(PAYMENT_RECIPIENT);

        assertEq(address(PAYMENT_RECIPIENT).balance, amount);
    }

    function testWithdrawWhenNotOwner(uint96 amount) public {
        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        vm.prank(OTHER_ADDRESS);
        vm.expectRevert("UNAUTHORIZED");
        token.withdraw(OTHER_ADDRESS);

        assertEq(address(token).balance, amount);
        assertEq(address(OTHER_ADDRESS).balance, 0 ether);
    }
}
