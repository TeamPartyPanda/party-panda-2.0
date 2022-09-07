// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC4883.sol";
import "../src/PartyPanda.sol";
import "./mocks/MockERC4883.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract PartyPandaTest is Test, ERC721Holder {
    PartyPanda public token;
    MockERC4883 public background;

    string constant TOKEN_NAME = "Token Name";
    uint256 constant PRICE = 0.000888 ether;
    address constant OWNER = 0xeB10511109053787b3ED6cc02d5Cb67A265806cC;

    function setUp() public {
        token = new PartyPanda();
        background = new MockERC4883("BACKGROUND", "BACK", PRICE, address(42), 10, 100);
    }

    function testMetadata() public {
        assertEq(token.name(), "Party Panda 2.0");
        assertEq(token.symbol(), "PP2");
        assertEq(token.price(), PRICE);
    }

    function testOwner() public {
        assertEq(token.owner(), OWNER);
    }

    function testSupportsERC4883() public {
        assertEq(token.supportsInterface(type(IERC4883).interfaceId), true);
    }

    /// Token Name

    function testTokenName() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        assertEq(token.tokenName(tokenId), "Party Panda 2.0 #1");
    }

    function testChangeTokenName(string memory tokenName) public {
        vm.assume(token.validateTokenName(tokenName));
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
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
        token.mint{value: PRICE}();

        vm.expectRevert(ERC4883.NotTokenOwner.selector);
        vm.prank(notTokenOwner);
        token.changeTokenName(tokenId, TOKEN_NAME);
    }

    function testChangeTokenNameInvalidTokenName(string memory tokenName) public {
        vm.assume(!token.validateTokenName(tokenName));

        uint256 tokenId = 1;
        token.mint{value: PRICE}();
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
