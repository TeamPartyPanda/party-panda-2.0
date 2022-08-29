// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Owned} from "solmate/auth/Owned.sol";
import {ERC721PayableMintable} from "../../src/ERC721PayableMintable.sol";

contract MockERC721PayableMintable is ERC721PayableMintable {
    string public constant NAME = "Name";
    string public constant SYMBOL = "SYM";

    uint256 public constant PRICE = 0.001 ether;
    uint256 public constant SUPPLY_CAP = 888;

    string public constant TOKEN_URI = "TOKEN_URI";

    constructor() ERC721PayableMintable(NAME, SYMBOL, PRICE, SUPPLY_CAP) Owned(msg.sender()) {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        return TOKEN_URI;
    }
}
