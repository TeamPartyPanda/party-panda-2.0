// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC4883.sol";
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

    string constant TOKEN_NAME = "Token Name";
    uint256 constant PRICE = 0.000888 ether;
    address constant OWNER = 0xeB10511109053787b3ED6cc02d5Cb67A265806cC;

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

    // Accessories
    function testAddAccessory() public {
        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        accessory1.approve(address(token), accessoryTokenId);
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);

        assertEq(accessory1.balanceOf(address(token)), 1);
    }

    function testAddAccessories() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);
    }

    function testAddAccessoriesMaximumAccessories() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();
        accessory4.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);

        accessory4.approve(address(token), 1);
        vm.expectRevert(PartyPanda2.MaximumAccessories.selector);
        token.addAccessory(tokenId, address(accessory4), 1);
    }

    function testAddAccessoryNonexistentToken(uint256 tokenId) public {
        uint256 accessoryTokenId = 1;
        accessory1.mint();

        accessory1.approve(address(token), accessoryTokenId);
        vm.expectRevert("ERC721: invalid token ID");
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);
    }

    function testAddAccessoryNotTokenOwner(address notTokenOwner) public {
        vm.assume(notTokenOwner != address(this));

        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        accessory1.approve(address(token), accessoryTokenId);

        vm.expectRevert(ERC4883.NotTokenOwner.selector);
        vm.prank(notTokenOwner);
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);
    }

    function testAddAccessoryNotERC4883() public {
        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        erc721.mint();

        erc721.approve(address(token), accessoryTokenId);

        vm.expectRevert(PartyPanda2.NotERC4883.selector);
        token.addAccessory(tokenId, address(erc721), accessoryTokenId);
    }

    function testAddAccessoryAlreadyAdded() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory1.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory1.approve(address(token), 2);

        vm.expectRevert(PartyPanda2.AccessoryAlreadyAdded.selector);
        token.addAccessory(tokenId, address(accessory1), 2);
    }

    function testAddAccessoryNotAccessoryOwner() public {
        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();

        vm.startPrank(OTHER_ADDRESS);
        accessory1.mint();
        accessory1.approve(address(token), accessoryTokenId);
        vm.stopPrank();

        vm.expectRevert(PartyPanda2.NotAccessoryOwner.selector);
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);
    }

    function testAddAccessoryNoAllowance() public {
        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        vm.expectRevert("ERC721: caller is not token owner nor approved");
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);
    }

    function testRemoveAccessory() public {
        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        accessory1.approve(address(token), accessoryTokenId);
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);
        token.removeAccessory(tokenId, address(accessory1), accessoryTokenId);

        assertEq(accessory1.balanceOf(address(this)), 1);
    }

    function testRemoveAccessories() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);

        token.removeAccessory(tokenId, address(accessory1), 1);
        token.removeAccessory(tokenId, address(accessory2), 1);
        token.removeAccessory(tokenId, address(accessory3), 1);
    }

    function testRemoveAccessoryNotTokenOwner(address notTokenOwner) public {
        vm.assume(notTokenOwner != address(this));

        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        accessory1.approve(address(token), accessoryTokenId);
        token.addAccessory(tokenId, address(accessory1), accessoryTokenId);

        vm.expectRevert(ERC4883.NotTokenOwner.selector);
        vm.prank(notTokenOwner);
        token.removeAccessory(tokenId, address(accessory1), accessoryTokenId);
    }

    function testRemoveAccessoryAccessoryNotFound(address notTokenOwner) public {
        vm.assume(notTokenOwner != address(this));

        uint256 tokenId = 1;
        uint256 accessoryTokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        vm.expectRevert(PartyPanda2.AccessoryNotFound.selector);
        token.removeAccessory(tokenId, address(accessory1), accessoryTokenId);
    }

    function testRemoveAccessoryDifferentTokenIdAccessoryNotFound(address notTokenOwner, uint256 otherTokenId) public {
        vm.assume(notTokenOwner != address(this));
        vm.assume(otherTokenId != 1);

        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();

        vm.expectRevert(PartyPanda2.AccessoryNotFound.selector);
        token.removeAccessory(tokenId, address(accessory1), otherTokenId);
    }

    function testRemoveAccessoriesAccessoryNotFound() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();
        accessory4.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);

        vm.expectRevert(PartyPanda2.AccessoryNotFound.selector);
        token.removeAccessory(tokenId, address(accessory4), 1);
    }

    function testRemoveAccessory1() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);

        token.removeAccessory(tokenId, address(accessory1), 1);
    }

    function testRemoveAccessory2() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);

        token.removeAccessory(tokenId, address(accessory2), 1);
    }

    function testRemoveAccessory3() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        accessory1.mint();
        accessory2.mint();
        accessory3.mint();

        accessory1.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory1), 1);

        accessory2.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory2), 1);

        accessory3.approve(address(token), 1);
        token.addAccessory(tokenId, address(accessory3), 1);

        token.removeAccessory(tokenId, address(accessory3), 1);
    }

    // Background
    function testAddBackground() public {
        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        background.mint();

        background.approve(address(token), backgroundTokenId);
        token.addBackground(tokenId, address(background), backgroundTokenId);
    }

    function testAddBackgroundNonexistentToken(uint256 tokenId) public {
        uint256 backgroundTokenId = 1;
        background.mint();

        background.approve(address(token), backgroundTokenId);
        vm.expectRevert("ERC721: invalid token ID");
        token.addBackground(tokenId, address(background), backgroundTokenId);
    }

    function testAddBackgroundNotTokenOwner(address notTokenOwner) public {
        vm.assume(notTokenOwner != address(this));

        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        background.mint();

        background.approve(address(token), backgroundTokenId);

        vm.expectRevert(ERC4883.NotTokenOwner.selector);
        vm.prank(notTokenOwner);
        token.addBackground(tokenId, address(background), backgroundTokenId);
    }

    function testAddBackgroundNotERC4883() public {
        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        erc721.mint();

        erc721.approve(address(token), backgroundTokenId);

        vm.expectRevert(PartyPanda2.NotERC4883.selector);
        token.addBackground(tokenId, address(erc721), backgroundTokenId);
    }

    function testAddBackgroundAlreadyAdded() public {
        uint256 tokenId = 1;
        token.mint{value: PRICE}();
        background.mint();
        background.mint();

        background.approve(address(token), 1);
        token.addBackground(tokenId, address(background), 1);

        background.approve(address(token), 2);

        vm.expectRevert(PartyPanda2.BackgroundAlreadyAdded.selector);
        token.addBackground(tokenId, address(background), 2);
    }

    function testAddBackgroundNotBackgroundOwner() public {
        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();

        vm.startPrank(OTHER_ADDRESS);
        background.mint();
        background.approve(address(token), backgroundTokenId);
        vm.stopPrank();

        vm.expectRevert(PartyPanda2.NotBackgroundOwner.selector);
        token.addBackground(tokenId, address(background), backgroundTokenId);
    }

    function testAddBackgroundNoAllowance() public {
        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        background.mint();

        vm.expectRevert("ERC721: caller is not token owner nor approved");
        token.addBackground(tokenId, address(background), backgroundTokenId);
    }

    function testRemoveBackground() public {
        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        background.mint();

        background.approve(address(token), backgroundTokenId);
        token.addBackground(tokenId, address(background), backgroundTokenId);
        token.removeBackground(tokenId);
    }

    function testRemoveBackgroundNotTokenOwner(address notTokenOwner) public {
        vm.assume(notTokenOwner != address(this));

        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        background.mint();

        background.approve(address(token), backgroundTokenId);
        token.addBackground(tokenId, address(background), backgroundTokenId);

        vm.expectRevert(ERC4883.NotTokenOwner.selector);
        vm.prank(notTokenOwner);
        token.removeBackground(tokenId);
    }

    function testRemoveBackgroundBackgroundAlreadyRemoved() public {
        uint256 tokenId = 1;
        uint256 backgroundTokenId = 1;
        token.mint{value: PRICE}();
        background.mint();

        background.approve(address(token), backgroundTokenId);
        token.addBackground(tokenId, address(background), backgroundTokenId);
        token.removeBackground(tokenId);

        vm.expectRevert(PartyPanda2.BackgroundAlreadyRemoved.selector);
        token.removeBackground(tokenId);
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
