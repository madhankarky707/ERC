// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {ERC721URIStorage} from "./extensions/ERC721URIStorage.sol";
import {Nestable} from "./nestable/Nestable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract ValorWar is AccessControl, Nestable, IERC721Metadata, ERC721URIStorage {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public constant MAX_ARMOR_TO_CHECK = 100;

    // Declaration of private member variable to hold the name of the warriors.
    string private _name;
    // Declaration of private member variable to hold the symbol of the warriors.
    string private _symbol;
    // Declaration of private member variable to hold the ID of the next warrior to be created.
    uint256 private _nextWarriorId;

    // Event triggered when a new warrior is spawned.
    event SpawnWarrior(uint256 indexed warriorId, address indexed to);
    // Event triggered when a warrior is destroyed.
    event DestroyWarrior(uint256 indexed warriorId, address indexed from);
    // Event triggered when a warrior is transferred from one address to another.
    event WarriorTransfer(address indexed from, address indexed to, uint256 indexed warriorId);
    // Event triggered when a nested warrior transfer occurs.
    event NestedWarriorTransfer(
        address indexed from,
        address indexed to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 indexed tokenId
    );

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol`.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        // Default admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // Operator role
        _grantRole(OPERATOR_ROLE, msg.sender);
        //mint initial warriors
        _initWarrior();
    }

    /**
    * @dev Sets the URI for a given token ID.
    * Accessible only by users with the OPERATOR_ROLE.
    * @param warriorId The ID of the token to set the URI for.
    * @param _warriorURI The URI to set for the token.
    */
    function setWarriorURI(uint256 warriorId, string memory _warriorURI) public virtual onlyRole(OPERATOR_ROLE) {
        _requireMinted(warriorId);
        _setTokenURI(warriorId, _warriorURI);
    }

    /**
    * @dev Spawns a new warrior and sends it to the specified address.
    * @param to The address to send the newly spawned warrior to.
    * @param _warriorURI The URI of the warrior.
    */
    function spawnWarrior(address to, string memory _warriorURI) public onlyRole(OPERATOR_ROLE) {
        uint256 _warriorId = ++_nextWarriorId;
        _mint(to, _warriorId, "");
        setWarriorURI(_warriorId, _warriorURI);
    }

    /**
    * @dev Destroys a warrior specified by its ID.
    * @param warriorId The ID of the warrior to be destroyed.
    */
    function sacrificeWarrior(uint256 warriorId) public {
        Child[] memory children = childrenOf(warriorId);
        uint256 length = children.length;
        burn(
            warriorId,
            length > MAX_ARMOR_TO_CHECK ? MAX_ARMOR_TO_CHECK : length
        );
    }

    /**
    * @dev Transfers armor from one token to another.
    * @param tokenId The ID of the token from which armor will be transferred.
    * @param to The address to which the armor will be transferred.
    * @param destinationId The ID of the destination token where the armor will be transferred.
    * @param childIndex The index of the child token.
    * @param childAddress The address of the child contract if armor is being transferred.
    * @param childId The ID of the child token if armor is being transferred.
    * @param isPending A boolean indicating whether the armor is pending or not.
    * @param data Additional data to pass along with the transfer.
    */
    function transferArmor(
        uint256 tokenId,
        address to,
        uint256 destinationId,
        uint256 childIndex,
        address childAddress,
        uint256 childId,
        bool isPending,
        bytes memory data
    ) public {
        transferChild(
            tokenId,
            to,
            destinationId,
            childIndex,
            childAddress,
            childId,
            isPending,
            data
        );
    }

    /**
    * @dev Initializes new warriors by minting them to the sender's address.
    */
    function _initWarrior() internal {
        _mint(msg.sender, ++_nextWarriorId, ""); //Zephyrion
        _mint(msg.sender, ++_nextWarriorId, ""); //Embera
        _mint(msg.sender, ++_nextWarriorId, ""); //Lunara
        _mint(msg.sender, ++_nextWarriorId, ""); //Ragnarok
    }

    /**
    * @dev Hook that is called after any token transfer.
    * @param from The address where the token is transferred from.
    * @param to The address where the token is transferred to.
    * @param tokenId The ID of the token that is transferred.
    */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._afterTokenTransfer(from,to, tokenId);
        if (from == address(0)) {
            emit SpawnWarrior(tokenId, to);
        } else if (to == address(0)) {
            emit DestroyWarrior(tokenId, from);
        } else {
            emit WarriorTransfer(
                from,
                to,
                tokenId
            );
        }
    }

    /**
    * @dev Hook that is called after transferring a nested token.
    * @param from The address from which the nested token is transferred.
    * @param to The address to which the nested token is transferred.
    * @param fromTokenId The ID of the token from which the nested token is transferred.
    * @param toTokenId The ID of the token to which the nested token is transferred.
    * @param tokenId The ID of the nested token that is transferred.
    * @param data Additional data to pass along with the transfer.
    */
    function _afterNestedTokenTransfer(
        address from,
        address to,
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 tokenId,
        bytes memory data
    ) internal virtual override {
        super._afterNestedTokenTransfer(from, to, fromTokenId, toTokenId, tokenId, data);
        emit NestedWarriorTransfer(
            from,
            to,
            fromTokenId,
            toTokenId,
            tokenId
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage, Nestable, AccessControl, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the owner of the specified token ID.
    * @param tokenId The ID of the token.
    * @return owner_ The address of the owner of the token.
    */
    function ownerOf(
        uint256 tokenId
    ) public view virtual override(Nestable, IERC721) returns (address owner_) {
        return super.ownerOf(tokenId);
    }

    /**
    * @dev Returns the URI for the specified token ID.
    * @param tokenId The ID of the token.
    * @return A string representing the URI of the token.
    */
    function tokenURI(uint256 tokenId) public view virtual override(IERC721Metadata, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
    * @dev Returns the URI for the specified warrior ID, which is the same as the token URI.
    * @param warriorId The ID of the warrior.
    * @return A string representing the URI of the warrior.
    */
    function warriorURI(uint256 warriorId) public view returns (string memory) {
        return tokenURI(warriorId);
    }

    /**
    * @dev Returns the base URI for all token URIs.
    * @return A string representing the base URI.
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return "";
    }    
}