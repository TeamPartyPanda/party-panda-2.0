// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4883} from "./ERC4883.sol";
import {IERC4883} from "./IERC4883.sol";
import {Colours} from "./Colours.sol";
import {Base64} from "@openzeppelin/contracts/utils//Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

// ██████╗  ██████╗ ██╗  ██╗
// ██╔══██╗██╔═══██╗╚██╗██╔╝
// ██████╔╝██║   ██║ ╚███╔╝
// ██╔══██╗██║   ██║ ██╔██╗
// ██████╔╝╚██████╔╝██╔╝ ██╗
// ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
contract Box is ERC4883, Colours {
    /// ERRORS

    /// EVENTS

    constructor() ERC4883("Box", "BOX", 0.00042 ether, 0xeB10511109053787b3ED6cc02d5Cb67A265806cC, 100, 4883) {}

    function _generateDescription(uint256 tokenId) internal view virtual override returns (string memory) {
        return string.concat("Box.  #", Strings.toString(tokenId), ".  ERC4883 composable NFT.");
    }

    function _generateAttributes(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory attributes = string.concat('{"trait_type": "Colour", "value": "', _generateColour(tokenId), '"}');

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateSVG(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory svg = string.concat(
            '<svg id="box" width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            _generateSVGBody(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _generateSVGBody(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory colourValue = _generateColour(tokenId);

        return string.concat(
            '<g id="box-',
            Strings.toString(tokenId),
            '">' "<desc>Just a box</desc>" '<rect x="20" y="20" width="460" height="460" fill="',
            colourValue,
            '" stroke="black" stroke-width="10" stroke-linejoin="round" />' "</g>"
        );
    }

    function _generateColour(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Box", address(this), Strings.toString(tokenId))));
        id = id % colours.length;
        return colours[id];
    }
}
