// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC4883.sol";
import "../src/Box.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract BoxTest is Test, ERC721Holder {
    Box public token;

    string public constant NAME = "Box";
    string public constant SYMBOL = "BOX";
    uint256 public constant OWNER_ALLOCATION = 100;
    uint256 public constant SUPPLY_CAP = 1000;
    uint256 constant PRICE = 0.00042 ether;
    address constant OWNER = 0xeB10511109053787b3ED6cc02d5Cb67A265806cC;

    string constant TOKEN_NAME = "Token Name";
    address constant OTHER_ADDRESS = address(23);

    function setUp() public {
        token = new Box();
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
}
