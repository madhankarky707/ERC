// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC404} from "./ERC404/ERC404.sol";
import {ERC404URIStorage} from "./extensions/ERC404URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "./ERC721/ERC721.sol";

contract Sample404 is ERC404, ERC404URIStorage, Ownable {
    constructor(
        address initOwner
    ) 
        ERC404(
            "Sample404", //name
            "S404", //symbol
            10_00_000 // supply
        )
        Ownable(initOwner)
    {
        _setWhitelist(initOwner, true);
    }

    function setWhitelist(address target, bool state) public onlyOwner {
        _setWhitelist(target, state);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Emits {MetadataUpdate}.
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    /**
     * @dev Checks whether the contract supports a given interface ID.
     * @param interfaceId The interface ID to check.
     * @return A boolean indicating whether the contract supports the given interface ID.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC404URIStorage, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Internal function to return the base URI for token metadata URIs.
     * @return The base URI for token metadata URIs.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC404URIStorage) returns (string memory) {
        return super.tokenURI( tokenId);
    }
}