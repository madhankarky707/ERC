// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SampleNFT1155 is 
    ERC1155,
    ERC1155Burnable,
    ERC1155URIStorage,
    ERC1155Pausable,
    Ownable
{
    constructor(address initOwner) ERC1155("https://ipfs.io/ipfs/") Ownable(initOwner) {}

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function setURI(uint256 tokenId, string memory tokenURI) external virtual onlyOwner {
        _setURI(tokenId, tokenURI);
    }

    /**
     * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function setBaseURI(string memory baseURI) external virtual onlyOwner {
        _setBaseURI(baseURI);
    }

    /**
     * @dev Creates a `value` amount of tokens of type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     */
    function mint(address to, uint256 id, uint256 value, bytes memory data) external onlyOwner {
        _mint(to, id, value, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) external onlyOwner {
        _mintBatch(to, ids, values, data);
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external  onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev Triggers start state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual override(ERC1155, ERC1155Pausable) {
        super._update(from, to, ids, values);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     */
    function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return super.uri(tokenId);
    }
}