// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721PayableMintableComposableSVG} from "../../src/ERC721PayableMintableComposableSVG.sol";

contract MockERC721PayableMintableComposableSVG is
    ERC721PayableMintableComposableSVG
{
    string public constant NAME = "Name";
    string public constant SYMBOL = "SYM";

    uint256 public constant PRICE = 0.001 ether;
    uint256 public constant SUPPLY_CAP = 888;

    string public constant TOKEN_URI = "TOKEN_URI";
    string public constant RENDER = "RENDER";

    constructor()
        ERC721PayableMintableComposableSVG(
            NAME,
            SYMBOL,
            PRICE,
            SUPPLY_CAP
        )
    {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        return TOKEN_URI;
    }

    function renderTokenById(uint256 id) external view returns (string memory) {
        return RENDER;
    }

    function foregroundName(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return _foregroundName(tokenId);
    }

    function backgroundName(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return _backgroundName(tokenId);
    }
}
