// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract SampleToken is ERC20, ERC20Capped, Ownable {
    uint256 constant initialSupply = 10_00_000; // Initial circulation
    uint256 constant MAX_SUPPLY = 100_00_000; // Maximun circulation

    constructor(address initOwner) ERC20("Sample Token", "ST") ERC20Capped(MAX_SUPPLY*(10**decimals())) Ownable(initOwner) {
        _mint(initOwner, initialSupply*(10**decimals()));
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }
}