// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4883} from "../../src/ERC4883.sol";

contract MockERC4883 is ERC4883 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 price_,
        address owner_,
        uint256 ownerAllocation_,
        uint256 supplyCap_
    )
        ERC4883(name_, symbol_, price_, owner_, ownerAllocation_, supplyCap_)
    {}

    function _generateDescription(uint256 tokenId) internal view virtual override returns (string memory) {
        return name();
    }

    function _generateAttributes(uint256 tokenId) internal view virtual override returns (string memory) {
        return string.concat('"attributes": []');
    }

    function _generateSVG(uint256 tokenId) internal view virtual override returns (string memory) {
        return "<svg></svg>";
    }

    function _generateSVGBody(uint256 tokenId) internal view virtual override returns (string memory) {
        return "<g></g>";
    }
}
