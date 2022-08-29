// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Owned} from "solmate/auth/Owned.sol";

abstract contract ERC721PayableMintable is ERC721, Owned {
    /// ERRORS

    /// @notice Thrown when underpaying
    error InsufficientPayment();

    /// @notice Thrown when supply cap reached
    error SupplyCapReached();

    /// @notice Thrown when token doesn't exist
    error NonexistentToken();

    /// EVENTS

    uint256 public totalSupply;

    uint256 public immutable price;
    uint256 public immutable supplyCap;

    bool private ownerMinted = false;

    constructor(string memory name_, string memory symbol_, uint256 price_, uint256 supplyCap_)
        ERC721(name_, symbol_)
    {
        price = price_;
        supplyCap = supplyCap_;
    }

    function mint() public payable {
        if (msg.value < price) {
            revert InsufficientPayment();
        }
        if (totalSupply >= supplyCap) {
            revert SupplyCapReached();
        }
        _mint();
    }

    function _mint() internal virtual {
        unchecked {
            totalSupply++;
        }
        _mint(msg.sender, totalSupply);
    }

    function withdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }
}
