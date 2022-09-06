// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PartyPanda.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract PartyPandaTest is Test, ERC721Holder {
    PartyPanda public token;

    string constant TOKEN_NAME = "Token Name";
    uint256 constant PAYMENT = 0.000888 ether;
    address constant OWNER = 0xeB10511109053787b3ED6cc02d5Cb67A265806cC;

    function setUp() public {
        token = new PartyPanda();
    }

    function testMetadata() public {
        assertEq(token.name(), "Party Panda 2.0");
        assertEq(token.symbol(), "PP2");
        assertEq(token.price(), PAYMENT);
    }

    function testOwner() public {
        assertEq(token.owner(), OWNER);
    }

    function testSupportsERC4883() public {
        assertEq(token.supportsInterface(type(IERC4883).interfaceId), true);
    }

    function testNoMint() public {
        assertEq(token.totalSupply(), 0);
    }

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

        vm.expectRevert(PartyPanda.InsufficientPayment.selector);
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

        vm.expectRevert(PartyPanda.SupplyCapReached.selector);
        token.mint{value: PAYMENT}();

        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap());
    }

    function testTokenUriNonexistentToken() public {
        uint256 tokenId = 1;
        vm.expectRevert(PartyPanda.NonexistentToken.selector);
        token.tokenURI(tokenId);
    }

    // function testOwnerMint() public {

    // }

    /// Payment

    function testWithdraw(uint96 amount) public {
        address recipient = address(2);

        vm.assume(amount >= PAYMENT);
        token.mint{value: amount}();

        vm.prank(OWNER);
        token.withdraw(recipient);

        assertEq(address(recipient).balance, amount);
        assertEq(address(token).balance, 0 ether);
    }

    function testWithdrawWhenNotOwner(uint96 amount, address nonOwner) public {
        address recipient = address(1);

        vm.assume(amount >= PAYMENT);
        vm.assume(nonOwner != OWNER);
        vm.assume(nonOwner != address(0));
        token.mint{value: amount}();

        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.withdraw(nonOwner);

        assertEq(address(token).balance, amount);
        assertEq(address(recipient).balance, 0 ether);
    }

    /// Owner Mint
    function testOwnerMint() public {
        vm.prank(OWNER);
        token.ownerMint();

        assertEq(token.totalSupply(), token.ownerAllocation());
        assertEq(token.ownerOf(1), OWNER);
        assertEq(token.ownerOf(token.ownerAllocation()), OWNER);
        assertEq(token.balanceOf(OWNER), token.ownerAllocation());
    }

    function testOwnerMintWhenNotOwner(address nonOwner) public {
        vm.assume(nonOwner != OWNER);
        vm.assume(nonOwner != address(0));

        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.ownerMint();

        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(address(nonOwner)), 0);
    }

    function testOwnerMintWhenOwnerAlreadyMinted() public {
        vm.prank(OWNER);
        token.ownerMint();

        vm.prank(OWNER);
        vm.expectRevert(PartyPanda.OwnerAlreadyMinted.selector);
        token.ownerMint();

        assertEq(token.totalSupply(), token.ownerAllocation());
        assertEq(token.balanceOf(address(OWNER)), token.ownerAllocation());
    }

    function testOwnerMintNearCap() public {
        for (uint256 index = 0; index < token.supplyCap() - 1; index++) {
            token.mint{value: PAYMENT}();
        }

        vm.prank(OWNER);
        token.ownerMint();

        assertEq(token.ownerOf(token.totalSupply()), OWNER);
        assertEq(token.totalSupply(), token.supplyCap());
        assertEq(token.balanceOf(address(this)), token.supplyCap() - 1);
        assertEq(token.balanceOf(address(OWNER)), 1);
    }

    /// Token Name

    function testTokenName() public {
        uint256 tokenId = 1;
        token.mint{value: PAYMENT}();
        assertEq(token.tokenName(tokenId), "Party Panda 2.0 #1");
    }

    function testChangeTokenName(string memory tokenName) public {
        vm.assume(token.validateTokenName(tokenName));
        uint256 tokenId = 1;
        token.mint{value: PAYMENT}();
        token.changeTokenName(tokenId, tokenName);

        assertEq(token.tokenName(tokenId), tokenName);
    }

    function testChangeTokenNameNonexistentToken(uint256 tokenId) public {
        vm.expectRevert("ERC721: invalid token ID");
        token.changeTokenName(tokenId, TOKEN_NAME);
    }

    function testChangeTokenNameNotTokenOwner(address notTokenOwner) public {
        vm.assume(notTokenOwner != address(this));

        uint256 tokenId = 1;
        token.mint{value: PAYMENT}();

        vm.expectRevert(PartyPanda.NotTokenOwner.selector);
        vm.prank(notTokenOwner);
        token.changeTokenName(tokenId, TOKEN_NAME);
    }

    function testChangeTokenNameInvalidTokenName(string memory tokenName) public {
        vm.assume(!token.validateTokenName(tokenName));

        uint256 tokenId = 1;
        token.mint{value: PAYMENT}();
        vm.expectRevert(PartyPanda.InvalidTokenName.selector);
        token.changeTokenName(tokenId, tokenName);

        assertEq(token.tokenName(tokenId), string.concat("Party Panda 2.0 #", Strings.toString(tokenId)));
    }

    function testValidateTokenNameEmptyString() public {
        assertTrue(!token.validateTokenName(""));
    }

    function testValidateTokenNameSpecialCharacters() public {
        assertTrue(!token.validateTokenName("-"));
    }

    function testValidateTokenNameLeadingSpace(string memory tokenName) public {
        vm.assume(token.validateTokenName(tokenName));

        assertTrue(!token.validateTokenName(string.concat(" ", tokenName)));
    }

    function testValidateTokenNameTrailingSpace(string memory tokenName) public {
        vm.assume(token.validateTokenName(tokenName));

        assertTrue(!token.validateTokenName(string.concat(tokenName, " ")));
    }

    function testValidateTokenNameMultipleSpaces() public {
        assertTrue(!token.validateTokenName(string.concat(TOKEN_NAME, "  ", TOKEN_NAME)));
    }

    function testValidateTokenNameTooLong() public {
        assertTrue(!token.validateTokenName("01234567890123456789012345"));
    }
}
