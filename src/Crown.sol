// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4883} from "./ERC4883.sol";
import {IERC4883} from "./IERC4883.sol";
import {Colours} from "./Colours.sol";
import {Base64} from "@openzeppelin/contracts/utils//Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

//  ▄████▄   ██▀███   ▒█████   █     █░███▄    █
// ▒██▀ ▀█  ▓██ ▒ ██▒▒██▒  ██▒▓█░ █ ░█░██ ▀█   █
// ▒▓█    ▄ ▓██ ░▄█ ▒▒██░  ██▒▒█░ █ ░█▓██  ▀█ ██▒
// ▒▓▓▄ ▄██▒▒██▀▀█▄  ▒██   ██░░█░ █ ░█▓██▒  ▐▌██▒
// ▒ ▓███▀ ░░██▓ ▒██▒░ ████▓▒░░░██▒██▓▒██░   ▓██░
// ░ ░▒ ▒  ░░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▓░▒ ▒ ░ ▒░   ▒ ▒
//   ░  ▒     ░▒ ░ ▒░  ░ ▒ ▒░   ▒ ░ ░ ░ ░░   ░ ▒░
// ░          ░░   ░ ░ ░ ░ ▒    ░   ░    ░   ░ ░
// ░ ░         ░         ░ ░      ░            ░
// ░
contract Crown is ERC4883, Colours {
    /// ERRORS

    /// EVENTS

    constructor() ERC4883("Crown", "CRWN", 0.00023 ether, 0xeB10511109053787b3ED6cc02d5Cb67A265806cC, 23, 230) {}

    function _generateDescription(uint256 tokenId) internal view virtual override returns (string memory) {
        return string.concat(
            "Crown.  #",
            Strings.toString(tokenId),
            ".  ERC4883 composable NFT.  Crown emoji designed by OpenMoji (the open-source emoji and icon project). License: CC BY-SA 4.0"
        );
    }

    function _generateAttributes(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory attributes = string.concat('{"trait_type": "Colour", "value": "', _generateColour(tokenId), '"}');

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateSVG(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory svg = string.concat(
            '<svg id="crown" width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            _generateSVGBody(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _generateSVGBody(uint256 tokenId) internal view virtual override returns (string memory) {
        string memory colourValue = _generateColour(tokenId);

        return string.concat(
            '<g id="crown-',
            Strings.toString(tokenId),
            '" fill="none">' "<desc>Crown emoji designed by OpenMoji. License: CC BY-SA 4.0</desc>"
            '<path d="M307.056 100.53H179.944v9.083h127.112v-9.083Zm-63.564-38.27c5.485 0 9.931-2.798 9.931-6.25s-4.446-6.25-9.931-6.25c-5.484 0-9.93 2.798-9.93 6.25s4.446 6.25 9.93 6.25Z" fill="#fff"/>'
            '<path d="M307.056 100.53H179.944v9.083h127.112v-9.083ZM185.903 49.75c5.484 0 9.93 2.798 9.93 6.25s-4.446 6.25-9.93 6.25m115.194 0c-5.484 0-9.93-2.798-9.93-6.25s4.446-6.25 9.93-6.25" fill="gold"/>'
            '<path d="M301.032 57.868c0 11.351-14.621 20.554-32.657 20.554h-.569c-18.036 0-22.727-9.203-22.727-20.554h-4.118c0 11.351-4.691 20.554-22.727 20.554h.326c-10.55 0-19.932-3.15-25.902-8.035-4.237-3.467-6.755-7.808-6.755-12.519V49.75v50.78h115.194V49.75" fill="gold"/>'
            '<path d="M243.492 62.26c5.485 0 9.931-2.798 9.931-6.25s-4.446-6.25-9.931-6.25c-5.484 0-9.93 2.798-9.93 6.25s4.446 6.25 9.93 6.25Z" fill="',
            colourValue,
            '"/>'
            '<path d="M307.056 100.53H179.944v9.083h127.112v-9.083ZM185.903 49.75v50.78h115.194V49.75" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M185.903 49.75c5.484 0 9.93 2.798 9.93 6.25s-4.446 6.25-9.93 6.25" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M218.56 78.422c-10.55 0-19.932-3.15-25.903-8.035-4.236-3.467-6.754-7.808-6.754-12.519m115.129 0c0 11.351-14.621 20.554-32.657 20.554M243.492 62.26c5.485 0 9.931-2.798 9.931-6.25s-4.446-6.25-9.931-6.25c-5.484 0-9.93 2.798-9.93 6.25s4.446 6.25 9.93 6.25Z" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M301.097 62.25c-5.484 0-9.93-2.798-9.93-6.25s4.446-6.25 9.93-6.25m5.959 50.78H179.944v9.083h127.112v-9.083ZM185.903 49.75c5.484 0 9.93 2.798 9.93 6.25s-4.446 6.25-9.93 6.25" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M301.097 62.25c-5.484 0-9.93-2.798-9.93-6.25s4.446-6.25 9.93-6.25" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M240.713 62.093c-1.167 9.325-6.744 16.329-22.479 16.329h.326c-10.55 0-19.932-3.15-25.902-8.035-4.237-3.467-6.755-7.808-6.755-12.519V49.75v50.78h115.194V49.75" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M301.032 57.868c0 11.351-14.621 20.554-32.657 20.554h-.569c-15.702 0-21.289-6.975-22.472-16.27" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            '<path d="M243.492 62.26c5.485 0 9.931-2.798 9.931-6.25s-4.446-6.25-9.931-6.25c-5.484 0-9.93 2.798-9.93 6.25s4.446 6.25 9.93 6.25Z" stroke="#000" stroke-width="6" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>'
            "</g>"
        );
    }

    function _generateColour(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Crown", address(this), Strings.toString(tokenId))));
        id = id % colours.length;
        return colours[id];
    }
}
