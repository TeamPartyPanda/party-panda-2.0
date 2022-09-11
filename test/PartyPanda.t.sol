// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC4883.sol";
import "../src/ERC4883Composer.sol";
import "../src/PartyPanda2.sol";
import "./mocks/MockERC4883.sol";
import "./mocks/MockERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract PartyPanda2Test is Test, ERC721Holder {
    PartyPanda2 public token;
    MockERC721 public erc721;
    MockERC4883 public background;
    MockERC4883 public accessory1;
    MockERC4883 public accessory2;
    MockERC4883 public accessory3;
    MockERC4883 public accessory4;

    string public constant NAME = "Party Panda 2.0";
    string public constant SYMBOL = "PP2";
    uint256 public constant OWNER_ALLOCATION = 100;
    uint256 public constant SUPPLY_CAP = 1000;
    uint256 constant PRICE = 0.000888 ether;
    address constant OWNER = 0xeB10511109053787b3ED6cc02d5Cb67A265806cC;

    string constant TOKEN_NAME = "Token Name";
    address constant OTHER_ADDRESS = address(23);

    function setUp() public {
        token = new PartyPanda2();
        erc721 = new MockERC721("ERC721", "NFT");
        background = new MockERC4883("Background", "BACK", 0, address(42), 10, 100);
        accessory1 = new MockERC4883("Accessory1", "ACC1", 0, address(42), 10, 100);
        accessory2 = new MockERC4883("Accessory2", "ACC2", 0, address(42), 10, 100);
        accessory3 = new MockERC4883("Accessory3", "ACC3", 0, address(42), 10, 100);
        accessory4 = new MockERC4883("Accessory4", "ACC4", 0, address(42), 10, 100);
    }

    function testMetadata() public {
        assertEq(token.name(), NAME);
        assertEq(token.symbol(), SYMBOL);
        assertEq(token.price(), PRICE);
    }

    function testOwner() public {
        assertEq(token.owner(), OWNER);
    }

    function testSupportsERC4883() public {
        assertEq(token.supportsInterface(type(IERC4883).interfaceId), true);
    }

    function testWithdraw(uint96 amount) public {
        address recipient = address(2);

        vm.assume(amount >= PRICE);
        token.mint{value: amount}();

        vm.prank(OWNER);
        token.withdraw(recipient);

        assertEq(address(recipient).balance, amount);
        assertEq(address(token).balance, 0 ether);
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
        vm.expectRevert(PartyPanda2.InvalidTokenName.selector);
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
