// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4883} from "./ERC4883.sol";
import {IERC4883} from "./IERC4883.sol";
import {Colours} from "./Colours.sol";
import {Base64} from "@openzeppelin/contracts/utils//Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

//      __                          ___ _
//   /\ \ \___  _   _ _ __  ___    / _ \ | __ _ ___ ___  ___  ___
//  /  \/ / _ \| | | | '_ \/ __|  / /_\/ |/ _` / __/ __|/ _ \/ __|
// / /\  / (_) | |_| | | | \__ \ / /_\\| | (_| \__ \__ \  __/\__ \
// \_\ \/ \___/ \__,_|_| |_|___/ \____/|_|\__,_|___/___/\___||___/
//
contract NounsGlasses is ERC4883, Colours {
    /// ERRORS

    /// EVENTS

    constructor()
        ERC4883("Nouns Glasses", "NGLS", 0.000202 ether, 0xeB10511109053787b3ED6cc02d5Cb67A265806cC, 200, 2020)
    {}

    function _generateDescription(uint256 tokenId) internal view virtual override returns (string memory) {
        return string.concat(
            "Nouns Glasses.  #",
            Strings.toString(tokenId),
            ".  ERC4883 composable NFT.  Nouns Glasses are inspired and derived from Nouns"
        );
    }

    function _generateAttributes(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory attributes = string.concat('{"trait_type": "Colour", "value": "', _generateColour(tokenId), '"}');

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
            '<g id="nounsglasses-',
            Strings.toString(tokenId),
            '">' "<desc>Nouns Glasses are inspired and derived from Nouns</desc>" '<g stroke="',
            colourValue,
            '" >' '<rect x="294" y="141" width="30" height="60" fill="black"/>'
            '<rect x="264" y="141" width="30" height="60" fill="white"/>'
            '<rect x="256.5" y="133.5" width="75" height="75" stroke-width="15" fill="none"/>'
            '<line x1="106.5" y1="201" x2="106.5" y2="171" stroke-width="15"/>'
            '<line x1="99" y1="163.5" x2="249" y2="163.5" stroke-width="15"/>'
            '<rect x="151.5" y="133.5" width="75" height="75" stroke-width="15" fill="none" />'
            '<rect x="159" y="141" width="30" height="60" fill="white"/>'
            '<rect x="189" y="141" width="30" height="60" fill="black"/>' "</g></g>"
        );
    }

    function _generateColour(uint256 tokenId) internal view returns (string memory) {
        uint256 id =
            uint256(keccak256(abi.encodePacked("Nouns Glasses Colour", address(this), Strings.toString(tokenId))));
        id = id % colours.length;
        return colours[id];
    }
}
