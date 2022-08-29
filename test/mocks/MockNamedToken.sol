// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {NamedToken} from "../../src/NamedToken.sol";

contract MockNamedToken is NamedToken {
    constructor() NamedToken("Mock NamedToken") {}

    function changeTokenName(uint256 tokenId, string memory newTokenName) external {
        _changeTokenName(tokenId, newTokenName);
    }
}
