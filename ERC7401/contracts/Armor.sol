// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {ERC721URIStorage} from "./extensions/ERC721URIStorage.sol";
import {Nestable} from "./nestable/Nestable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract ArmoredForge is Nestable, IERC721Metadata, ERC721URIStorage, AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // Declaration of private member variable to hold the name of the armors.
    string private _name;
    // Declaration of private member variable to hold the symbol of the armors.
    string private _symbol;
    // Declaration of private member variable to hold the ID of the next armor to be created.
    uint256 private _nextArmorId;

    // Emitted when armor is forged and assigned to a warrior.
    event ForgeArmor(uint256 indexed warriorId, address indexed to);
    //  Emitted when armor is shattered and removed from a warrior.
    event ShatterArmor(uint256 indexed warriorId, address indexed from);
    // Emitted when armor is transferred from one owner to another.
    event ArmorTransfer(address indexed from, address indexed to, uint256 indexed warriorId);
    // Emitted when armor is transferred between nested tokens (e.g. from one warrior to another).
    event NestedArmorTransfer(
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
        //mint initial armors
        _mintInitialArmors();
    }

    /**
     * @dev Sets the URI for a given token ID.
     * Accessible only by users with the OPERATOR_ROLE.
     * @param armorId The ID of the token to set the URI for.
     * @param _tokenURI The URI to set for the token.
     */
    function setArmorURI(uint256 armorId, string memory _tokenURI) public virtual onlyRole(OPERATOR_ROLE) {
        _requireMinted(armorId);
        _setTokenURI(armorId, _tokenURI);
    }

    /**
     * @dev Creates a new armor token and assigns it to the specified address.
     * @param to The address to which the new armor token will be assigned.
     * @param _armorURI The URI for the new armor token.
     */
    function forgeArmor(address to, string memory _armorURI) public onlyRole(OPERATOR_ROLE) {
        uint256 _armorId = ++_nextArmorId;
        _mint(to, _armorId, "");
        setArmorURI(_armorId, _armorURI);
    }

    /**
     * @dev Creates a new armor token and assigns it to a specified warrior.
     * @param warriorContractAddress The address of the warrior contract.
     * @param warriorId The ID of the warrior to which the new armor token will be assigned.
     * @param _armorURI The URI for the new armor token.
     */
    function forgeArmorToWarrior(address warriorContractAddress, uint256 warriorId, string memory _armorURI) public onlyRole(OPERATOR_ROLE) {
        uint256 _armorId = ++_nextArmorId;
        _nestMint(
            warriorContractAddress,
            _armorId,
            warriorId,
            ""
        );
        setArmorURI(_armorId, _armorURI);
    }

    /**
     * @dev Transfers an existing armor token to a warrior contract.
     * @param armorOwner The current owner of the armor token.
     * @param warriorContractAddress The address of the warrior contract.
     * @param armorId The ID of the armor token to be transferred.
     * @param warriorId The ID of the warrior to which the armor token will be assigned.
     * @param data Additional data to pass along with the transfer.
     */
    function addArmorToWarrior(
        address armorOwner,
        address warriorContractAddress,
        uint256 armorId,
        uint256 warriorId,
        bytes memory data
    ) public {
        nestTransferFrom(
            armorOwner,
            warriorContractAddress,
            armorId,
            warriorId,
            data
        );
    }

    /**
     * @dev Initializes new armors by minting them to the sender's address.
     */
    function _mintInitialArmors() internal {
        _mint(msg.sender, ++_nextArmorId, ""); //Helmet
        _mint(msg.sender, ++_nextArmorId, ""); //Backplate
        _mint(msg.sender, ++_nextArmorId, ""); //Greaves
        _mint(msg.sender, ++_nextArmorId, ""); //Gorget
        _mint(msg.sender, ++_nextArmorId, ""); //Cuirass
        _mint(msg.sender, ++_nextArmorId, ""); //Vambraces
        _mint(msg.sender, ++_nextArmorId, ""); //Gauntlets
        _mint(msg.sender, ++_nextArmorId, ""); //Cuisses
        _mint(msg.sender, ++_nextArmorId, ""); //Sabatons
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
            emit ForgeArmor(tokenId, to);
        } else if (to == address(0)) {
            emit ShatterArmor(tokenId, from);
        } else {
            emit ArmorTransfer(
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
        emit NestedArmorTransfer(
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
     * @dev Returns the base URI for all token URIs.
     * @return A string representing the base URI.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "";
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
     * @dev Returns the URI for the specified armor ID
     * @param armorId The ID of the armor.
     * @return A string representing the URI of the armor.
     */
    function armorURI(uint256 armorId) public view returns (string memory) {
        return tokenURI(armorId);
    }
}