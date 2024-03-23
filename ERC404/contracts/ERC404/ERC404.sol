//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20Errors} from "../interfaces/draft-IERC6093.sol";
import {ERC721} from "../ERC721/ERC721.sol";

abstract contract ERC404 is ERC721, IERC20Errors {
    using Strings for uint256;
    
    event ERC20Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event ERC20Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed amount
    );

    // This error is thrown when an action is attempted by an unauthorized user.
    error Unauthorized();
    // This error is thrown when an attempt is made to create or add a token with a token ID that already exists.
    error AlreadyExists(uint256 tokenId);

    uint256 private immutable _totalSupply;
    uint256 public minted;

    mapping(address account => mapping(address spender => uint256)) private _allowances;
    // Mapping to store the tokens owned by each address.
    mapping(address => uint256[]) internal _owned;
    // Mapping to store the index of each token ID within the _owned array.
    mapping(uint256 => uint256) internal _ownedIndex;
    // Mapping to store whether an address is whitelisted.
    mapping(address => bool) public whitelist;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply
    )
        ERC721(name_, symbol_)
    {
        _totalSupply = maxSupply*_getUnit();
        _increaseBalance(msg.sender, _totalSupply);
        emit ERC20Transfer(
            address(0),
            msg.sender,
            _totalSupply
        );
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Approves address to transfer the specified token ID or units.
     * @param to The address to which to grant approval for token transfer.
     * @param tokenId The ID of the token or units to be approved.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        if (tokenId <= minted && tokenId > 0) {
            super.approve(to, tokenId);
        } else {
            _approve(msg.sender, to, tokenId, true);
        }
    }

    /**
     * @dev Transfers a token with the specified ID or units.
     * @param from The address from which to transfer the token.
     * @param to The address to which to transfer the token.
     * @param id The ID of the token or units to be transferred.
     */
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        if (id <= minted) {
            super.transferFrom(from, to, id);
            _updatePushAndPop(from, to, id);
            emit ERC20Transfer(from, to, _getUnit());
        } else {
            if (allowance(from, msg.sender) != type(uint256).max)
                _spendAllowance(from, msg.sender, id);

            _transfers(from, to, id);
        }
    }

    /**
     * @dev Transfers a specified amount of uint.
     * @param to The address of the recipient to whom the tokens will be transferred.
     * @param amount The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful.
     */
    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        return _transfers(msg.sender, to, amount);
    }

    /**
     * @dev Internal function to set the whitelist state for a specific address.
     * @param target The address for which to set the whitelist state.
     * @param state The boolean state indicating whether the address should be whitelisted or not.
     */
    function _setWhitelist(address target, bool state) internal {
        whitelist[target] = state;
    }

    /**
     * @dev Internal function to transfer tokens from one address to another.
     * @param from The address from which to transfer tokens.
     * @param to The address to which to transfer tokens.
     * @param amount The amount of uint to transfer.
     * @return A boolean indicating whether the transfer was successful.
     */
    function _transfers(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 unit = _getUnit();
        uint256 balanceBeforeSender = balanceOf(from);
        uint256 balanceBeforeReceiver = balanceOf(to);

        _decreaseBalance(from, amount);
        _increaseBalance(to, amount);

        if (!whitelist[from]) {
            uint256 tokens_to_burn = (balanceBeforeSender / unit) -
                (balanceOf(from) / unit);
            for (uint256 i = 0; i < tokens_to_burn; i++) {
                _burn(from);
            }
        }

        if (!whitelist[to]) {
            uint256 tokens_to_mint = (balanceOf(to) / unit) -
                (balanceBeforeReceiver / unit);
            for (uint256 i = 0; i < tokens_to_mint; i++) {
                _mint(to);
            }
        }

        emit ERC20Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Internal function to update the ownership of a token and adjust balances accordingly.
     * @param to The address to which ownership of the token will be transferred.
     * @param tokenId The ID of the token to be updated.
     * @param auth The address authorized to perform the update (optional).
     * @return The address of the previous owner of the token.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= _getUnit();
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += _getUnit();
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

    /**
     * @dev Internal function to update the ownership arrays after a token transfer.
     * @param from The address from which the token is being transferred.
     * @param to The address to which the token is being transferred.
     * @param tokenId The ID of the token being transferred.
     */
    function _updatePushAndPop(address from, address to, uint256 tokenId) internal virtual {
        uint256 updatedId = _owned[from][_owned[from].length - 1];
        _owned[from][_ownedIndex[tokenId]] = updatedId;
        _owned[from].pop();
        _ownedIndex[updatedId] = _ownedIndex[tokenId];
        _owned[to].push(tokenId);
        _ownedIndex[tokenId] = _owned[to].length - 1;
    }

    /**
     * @dev Internal function to mint a new token and assign ownership to the specified address.
     * @param to The address to which ownership of the minted token will be assigned.
     */
    function _mint(address to) internal virtual {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(to);
        }

        unchecked {
            minted++;
        }

        uint256 id = minted;

        if (_owners[id] != address(0)) {
            revert AlreadyExists(id);
        }

        _owners[id] = to;
        _owned[to].push(id);
        _ownedIndex[id] = _owned[to].length - 1;

        emit Transfer(address(0), to, id);
    }

    /**
     * @dev Internal function to burn (destroy) a token owned by the specified address.
     * @param from The address of the token owner from which the token will be burned.
     */
    function _burn(address from) internal virtual {
        if (from == address(0)) {
            revert ERC721InvalidSender(from);
        }

        uint256 id = _owned[from][_owned[from].length - 1];
        _owned[from].pop();
        delete _ownedIndex[id];
        delete _owners[id];
        // delete _tokenApprovals[id];

        emit Transfer(from, address(0), id);
    }

    /**
     * @dev Internal function to retrieve the token unit value (10^decimals).
     * @return The unit value of the token.
     */
    function _getUnit() internal view returns (uint256) {
        return 10 ** decimals();
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit ERC20Approval(owner, spender, value);
        }
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
}