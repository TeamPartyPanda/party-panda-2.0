// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4883} from "./ERC4883.sol";
import {IERC4883} from "./IERC4883.sol";
import {Colours} from "./Colours.sol";
import {Base64} from "@openzeppelin/contracts/utils//Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract NounsGlasses is ERC4883, Colours {
    /// ERRORS

    /// EVENTS

    constructor()
        ERC4883("Nouns Glasses", "PNG", 0.000888 ether, 0xeB10511109053787b3ED6cc02d5Cb67A265806cC, 200, 2020)
    {}

    function _generateAttributes(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory attributes = string.concat('{"trait_type": "colour", "value": "', _generateColour(tokenId), '"}');

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateSVG(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory svg = string.concat(
            '<svg id="nounsglasses" width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            _generateSVGBody(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _generateSVGBody(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory colourValue = _generateColour(tokenId);

        return string.concat(
            '<g id="nounsglasses',
            Strings.toString(tokenId),
            '">' "<desc>Nouns Glasses are inspired and derived from Nouns</desc>" '<g stroke="',
            colourValue,
            '" stroke-width="15">' '<rect x="255.5" y="137.5" width="75" height="75" />'
            '<line x1="105.5" y1="205" x2="105.5" y2="175" />' '<line x1="98" y1="167.5" x2="248" y2="167.5" />'
            '<rect x="150.5" y="137.5" width="75" height="75" />' "</g>"
            '<rect x="293" y="145" width="30" height="60" fill="black"/>'
            '<rect x="263" y="145" width="30" height="60" fill="white"/>'
            '<rect x="188" y="145" width="30" height="60" fill="black"/>'
            '<rect x="158" y="145" width="30" height="60" fill="white"/>' "</g>"
        );
    }

    function _generateColour(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Colour", address(this), Strings.toString(tokenId))));
        id = id % colours.length;
        return colours[id];
    }
}
