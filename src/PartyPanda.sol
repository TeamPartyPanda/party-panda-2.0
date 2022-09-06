// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC4883} from "./IERC4883.sol";
import {Base64} from "@openzeppelin/contracts/utils//Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract PartyPanda is ERC721, Ownable, IERC4883 {
    /// ERRORS

    /// @notice Thrown when supply cap reached
    error SupplyCapReached();

    /// @notice Thrown when underpaying
    error InsufficientPayment();

    /// @notice Thrown when token doesn't exist
    error NonexistentToken();

    /// @notice Thrown when attempting to set an invalid token name
    error InvalidTokenName();

    /// @notice Thrown when attempting to call when not the owner
    error NotTokenOwner();

    /// @notice Thrown when owner already minted
    error OwnerAlreadyMinted();

    /// @notice Thrown when token doesn't implement ERC4883
    error NotERC4883();

    /// @notice Thrown when background already added
    error BackgroundAlreadyAdded();

    /// @notice Thrown when background already added
    error BackgroundAlreadyRemoved();

    /// EVENTS

    /// @notice Emitted when background added
    event BackgroundAdded(uint256 tokenId, address backgroundToken, uint256 backgroundTokenId);

    /// @notice Emitted when background removed
    event BackgroundRemoved(uint256 tokenId, address backgroundToken, uint256 backgroundTokenId);

    /// @notice Emitted when name changed
    event TokenNameChange(uint256 indexed tokenId, string tokenName);

    uint256 public totalSupply;
    uint256 public immutable supplyCap;

    bool private ownerMinted = false;
    uint256 public immutable ownerAllocation;

    uint256 public immutable price;

    mapping(uint256 => string) private _names;

    struct Token {
        address tokenAddress;
        uint256 tokenId;
    }

    struct Composable {
        Token background;
        Token[] accessories;
    }

    mapping(uint256 => Composable) public composables;

    string[] colors = [
        "AliceBlue",
        "AntiqueWhite",
        "Aqua",
        "Aquamarine",
        "Azure",
        "Beige",
        "Bisque",
        "Black",
        "BlanchedAlmond",
        "Blue",
        "BlueViolet",
        "Brown",
        "BurlyWood",
        "CadetBlue",
        "Chartreuse",
        "Chocolate",
        "Coral",
        "CornflowerBlue",
        "Cornsilk",
        "Crimson",
        "Cyan",
        "DarkBlue",
        "DarkCyan",
        "DarkGoldenRod",
        "DarkGreen",
        "DarkGrey",
        "DarkKhaki",
        "DarkMagenta",
        "DarkOliveGreen",
        "DarkOrange",
        "DarkOrchid",
        "DarkRed",
        "DarkSalmon",
        "DarkSeaGreen",
        "DarkSlateBlue",
        "DarkSlateGrey",
        "DarkTurquoise",
        "DarkViolet",
        "DeepPink",
        "DeepSkyBlue",
        "DimGrey",
        "DodgerBlue",
        "FireBrick",
        "FloralWhite",
        "ForestGreen",
        "Fuchsia",
        "Gainsboro",
        "GhostWhite",
        "Gold",
        "GoldenRod",
        "Green",
        "GreenYellow",
        "Grey",
        "HoneyDew",
        "HotPink",
        "IndianRed",
        "Indigo",
        "Ivory",
        "Khaki",
        "Lavender",
        "LavenderBlush",
        "LawnGreen",
        "LemonChiffon",
        "LightBlue",
        "LightCoral",
        "LightCyan",
        "LightGoldenRodYellow",
        "LightGreen",
        "LightGrey",
        "LightPink",
        "LightSalmon",
        "LightSeaGreen",
        "LightSkyBlue",
        "LightSlateGrey",
        "LightSteelBlue",
        "LightYellow",
        "Lime",
        "LimeGreen",
        "Linen",
        "Magenta",
        "Maroon",
        "MediumAquaMarine",
        "MediumBlue",
        "MediumOrchid",
        "MediumPurple",
        "MediumSeaGreen",
        "MediumSlateBlue",
        "MediumSpringGreen",
        "MediumTurquoise",
        "MediumVioletRed",
        "MidnightBlue",
        "MintCream",
        "MistyRose",
        "Moccasin",
        "NavajoWhite",
        "Navy",
        "OldLace",
        "Olive",
        "OliveDrab",
        "Orange",
        "OrangeRed",
        "Orchid",
        "PaleGoldenRod",
        "PaleGreen",
        "PaleTurquoise",
        "PaleVioletRed",
        "PapayaWhip",
        "PeachPuff",
        "Peru",
        "Pink",
        "Plum",
        "PowderBlue",
        "Purple",
        "RebeccaPurple",
        "Red",
        "RosyBrown",
        "RoyalBlue",
        "SaddleBrown",
        "Salmon",
        "SandyBrown",
        "SeaGreen",
        "SeaShell",
        "Sienna",
        "Silver",
        "SkyBlue",
        "SlateBlue",
        "SlateGrey",
        "Snow",
        "SpringGreen",
        "SteelBlue",
        "Tan",
        "Teal",
        "Thistle",
        "Tomato",
        "Turquoise",
        "Violet",
        "Wheat",
        "White",
        "WhiteSmoke",
        "Yellow",
        "YellowGreen"
    ];

    string[] personalities = ["Playful", "Friendly", "Curious", "Energetic", "Gentle", "Zazzy"];

    constructor() ERC721("Party Panda 2.0", "PP2") {
        _transferOwnership(0xeB10511109053787b3ED6cc02d5Cb67A265806cC);
        supplyCap = 999;
        price = 0.000888 ether;
        ownerAllocation = 175;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC721, IERC165) returns (bool) {
        return interfaceId == type(IERC4883).interfaceId || super.supportsInterface(interfaceId);
    }

    function mint(address to) public payable {
        if (msg.value < price) {
            revert InsufficientPayment();
        }
        if (totalSupply >= supplyCap) {
            revert SupplyCapReached();
        }

        _mint();
    }

    function mint() public payable {
        mint(msg.sender);
    }

    function ownerMint() public onlyOwner {
        if (ownerMinted) {
            revert OwnerAlreadyMinted();
        }

        uint256 available = ownerAllocation;
        if (totalSupply + ownerAllocation > supplyCap) {
            available = supplyCap - totalSupply;
        }

        for (uint256 index = 0; index < available;) {
            _mint();

            unchecked {
                ++index;
            }
        }

        ownerMinted = true;
    }

    function _mint() private {
        unchecked {
            totalSupply++;
        }

        _safeMint(msg.sender, totalSupply);
    }

    function withdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert NonexistentToken();
        }

        string memory tokenName_ = string.concat(_generateColour(tokenId), " Party Panda");
        string memory description = "Party Panda 2.0";

        string memory image = _generateBase64Image(tokenId);
        string memory attributes = _generateAttributes(tokenId);
        return string.concat(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '{"name":"',
                        tokenName_,
                        '", "description":"',
                        description,
                        '", "image": "data:image/svg+xml;base64,',
                        image,
                        '",',
                        attributes,
                        "}"
                    )
                )
            )
        );
    }

    function _generateAttributes(uint256 tokenId) internal view returns (string memory) {
        string memory attributes = string.concat(
            '{"trait_type": "colour", "value": "',
            _generateColour(tokenId),
            '"}, {"trait_type": "personality", "value": "',
            _generatePersonality(tokenId),
            '"}'
        );

        return string.concat('"attributes": [', attributes, "]");
    }

    function _generateBase64Image(uint256 tokenId) internal view returns (string memory) {
        return Base64.encode(bytes(_generateSVG(tokenId)));
    }

    function _generateSVG(uint256 tokenId) internal view returns (string memory) {
        string memory svg = string.concat(
            '<svg id="partypanda2" width="500" height="500" viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">',
            _generateBackground(tokenId),
            _generateSVGBody(tokenId),
            _generateAccessories(tokenId),
            "</svg>"
        );

        return svg;
    }

    function _generateSVGBody(uint256 tokenId) internal view returns (string memory) {
        string memory colourValue = _generateColour(tokenId);

        return string.concat(
            '<g id="partypanda">' "<desc>Party Panda is Copyright 2022 by Alex Party Panda https://github.com/AlexPartyPanda</desc>"
'<g fill="', colourValue, '">'
'<path d="M141.746 364.546C88.0896 338.166 67.7686 339.117 54.9706 378.618C58.0112 418.292 64.3272 429.537 80.7686 437.25C104.636 448.709 170.876 432.772 247.283 422.005C354.846 435.377 424.823 445.054 438.422 437.25C458.371 424.569 466.499 414.297 464.22 378.618C445.099 351.034 433.356 339.684 403.243 356.338L365.719 336.403L141.746 364.546Z" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M289.498 101.876C331.996 80.7832 329.868 101.341 328.195 149.954L289.498 101.876Z" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M166.371 134.71C159.627 93.6161 168.829 83.778 208.586 96.0128L166.371 134.71Z" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'</g>'
'<path d="M328.195 149.954C287.152 66.6969 206.241 66.6969 162.853 142.918C142.529 198.634 141.272 222.583 172.234 241.419C236.394 285.393 269.181 279.975 334.058 241.419C342.266 228.521 349.3 182.978 328.195 149.954Z" fill="#FFFAFA" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M182.788 416.142L172.234 319.986H305.915V425.523C267.207 438.31 226.501 448.015 182.788 416.142Z" fill="#FFFAFA" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M203.895 438.422C188.866 441.956 126.168 466.883 112.43 429.041C113.412 402.012 115.628 378.479 120.983 355.165C128.972 320.386 143.947 286.097 172.234 241.42C237.262 281.898 267.857 272.611 332.885 242.592C361.052 282.666 377.85 317.581 377.663 346.957C377.6 356.842 380.012 367.162 377.663 378.618C377.663 378.618 373.927 400.898 373.927 429.041C373.927 457.185 297.706 465.393 289.498 429.041C281.289 392.69 286.505 410.486 297.706 346.957C263.52 339.96 240.669 340.596 195.687 346.957C202.359 358.413 218.925 434.889 203.895 438.422Z" fill="', colourValue, '" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M294.188 133.537C278.558 140.565 272.033 146.383 264.872 160.508C283.729 170.948 293.316 180.152 308.26 203.895L321.159 186.306C315.382 159.43 310.699 146.264 294.188 133.537Z" fill="', colourValue, '" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M207.241 139.228C219.2 152.324 213.673 152.092 217.794 160.335C206.104 161.8 197.052 169.693 176.752 195.514C174.004 187.729 173.302 187.34 169.716 175.579C166.131 163.819 195.281 126.131 207.241 139.228Z" fill="', colourValue, '" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M244.5 271.287C324.5 271.287 334 160.882 240 160.882C146 160.882 164.5 271.287 244.5 271.287Z" fill="#FFFAFA" stroke="black" stroke-width="7.62"/>'
'<path d="M215.622 195.687C226.175 185.133 255.491 189.824 260.182 198.032C248.455 209.758 227.348 207.413 215.622 195.687Z" fill="black" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<path d="M221.485 228.521C242.829 237.607 245.499 236.723 263.7 228.521" stroke="black" stroke-width="7.62162" stroke-linecap="round" stroke-linejoin="round"/>'
'<circle cx="194.169" cy="165.026" r="9.38108" fill="black"/>'
'<circle cx="285.98" cy="166.371" r="9.38108" fill="black"/>'

            "</g>"
        );
    }

    function _generateBackground(uint256 tokenId) internal view returns (string memory) {
        string memory background = "";

        if (composables[tokenId].background.tokenAddress != address(0)) {
            background = IERC4883(composables[tokenId].background.tokenAddress).renderTokenById(
                composables[tokenId].background.tokenId
            );
        }

        return background;
    }

    function _generateAccessories(uint256 tokenId) internal view returns (string memory) {
        string memory accessories = "";

        uint256 length = composables[tokenId].accessories.length;

        for (uint256 index = 0; index < length;) {
            if (composables[tokenId].accessories[index].tokenAddress != address(0)) {
                accessories = string.concat(
                    accessories,
                    IERC4883(composables[tokenId].accessories[index].tokenAddress).renderTokenById(
                        composables[tokenId].accessories[index].tokenId
                    )
                );
            }

            unchecked {
                ++index;
            }
        }

        return accessories;
    }

    function _generateColour(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Colour", address(this), Strings.toString(tokenId))));
        id = id % colors.length;
        return colors[id];
    }

    function _generatePersonality(uint256 tokenId) internal view returns (string memory) {
        uint256 id = uint256(keccak256(abi.encodePacked("Personality", address(this), Strings.toString(tokenId))));
        id = id % personalities.length;
        return personalities[id];
    }

    function renderTokenById(uint256 tokenId) public view returns (string memory) {
        if (!_exists(tokenId)) {
            revert NonexistentToken();
        }

        return string.concat(_generateBackground(tokenId), _generateSVGBody(tokenId), _generateAccessories(tokenId));
    }

    function addBackground(uint256 tokenId, address backgroundTokenAddress, uint256 backgroundTokenId) public {
        address tokenOwner = ownerOf(tokenId);
        if (tokenOwner != msg.sender) {
            revert NotTokenOwner();
        }

        IERC4883 backgroundToken = IERC4883(backgroundTokenAddress);

        if (!backgroundToken.supportsInterface(type(IERC4883).interfaceId)) {
            revert NotERC4883();
        }

        if (composables[tokenId].background.tokenAddress != address(0)) {
            revert BackgroundAlreadyAdded();
        }

        composables[tokenId].background = Token(backgroundTokenAddress, backgroundTokenId);

        backgroundToken.safeTransferFrom(tokenOwner, address(this), backgroundTokenId);

        emit BackgroundAdded(tokenId, backgroundTokenAddress, backgroundTokenId);
    }

    function removeBackground(uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        if (tokenOwner != msg.sender) {
            revert NotTokenOwner();
        }

        Token memory background = composables[tokenId].background;

        if (background.tokenAddress == address(0)) {
            revert BackgroundAlreadyRemoved();
        }

        composables[tokenId].background = Token(address(0), 0);

        IERC4883 backgroundToken = IERC4883(background.tokenAddress);
        backgroundToken.safeTransferFrom(address(this), tokenOwner, background.tokenId);

        emit BackgroundRemoved(tokenId, background.tokenAddress, background.tokenId);
    }

    function tokenName(uint256 tokenId) public view returns (string memory) {
        string memory _name = _names[tokenId];

        bytes memory b = bytes(_name);
        if (b.length < 1) {
            _name = string.concat(name(), " #", Strings.toString(tokenId));
        }

        return _name;
    }

    // Based on The HashMarks
    // https://etherscan.io/address/0xc2c747e0f7004f9e8817db2ca4997657a7746928#code#F7#L311
    function changeTokenName(uint256 tokenId, string memory newTokenName) public {
        if (ownerOf(tokenId) != msg.sender) {
            revert NotTokenOwner();
        }

        if (!validateTokenName(newTokenName)) {
            revert InvalidTokenName();
        }

        _names[tokenId] = newTokenName;

        emit TokenNameChange(tokenId, newTokenName);
    }

    // From The HashMarks
    // https://etherscan.io/address/0xc2c747e0f7004f9e8817db2ca4997657a7746928#code#F7#L612
    function validateTokenName(string memory str) public pure returns (bool) {
        bytes memory b = bytes(str);
        if (b.length < 1) {
            return false;
        }
        if (b.length > 25) {
            return false;
        } // Cannot be longer than 25 characters
        if (b[0] == 0x20) {
            return false;
        } // Leading space
        if (b[b.length - 1] == 0x20) {
            return false;
        } // Trailing space

        bytes1 lastChar = b[0];

        for (uint256 i; i < b.length; i++) {
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) {
                return false;
            } // Cannot contain continous spaces

            if (
                !(char >= 0x30 && char <= 0x39) //9-0
                    && !(char >= 0x41 && char <= 0x5A) //A-Z
                    && !(char >= 0x61 && char <= 0x7A) //a-z
                    && !(char == 0x20)
            ) {
                //space
                return false;
            }

            lastChar = char;
        }

        return true;
    }
}
