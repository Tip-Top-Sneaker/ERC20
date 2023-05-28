// SPDX-License-Identifier: MIT
// FunnyTokenContract.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./Blacklist.sol";
import "./RateLimiter.sol";
import "./MaxTransfer.sol";
import "./BurnFee.sol";

// The MyToken contract inherits from the ERC20 contract, and includes additional features for blacklisting addresses, limiting transaction rate, and limiting maximum transfer amount.
contract MyToken is ERC20Upgradeable, AccessControlUpgradeable, Blacklist, RateLimiter, MaxTransfer, BurnFee {
    // Define a new role identifier for the minter.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public feeCollector;

    // Replace the constructor with an initializer function.
    function initialize()  public  initializer {
        __ERC20_init("Funny Token", "FUC");
        __AccessControl_init();

        uint256 initialSupply = 1000000000 * (10 ** uint256(decimals())); // 1 billion tokens
        _mint(msg.sender, initialSupply);
        _setupRole(MINTER_ROLE, msg.sender);
        

        // Initialize the other contracts with their default values
        //Blacklist.initialize();
        RateLimiter.initialize();
        MaxTransfer.initialize(decimals());
        BurnFee.initialize();
    
        RateLimiter.setMinTimeBetweenTransfers(30 minutes); // 30 mins transaction interval
        MaxTransfer.setMaxTransferAmount(50000 * (10 ** uint256(decimals()))); // Max 50K FUC token per trade
        BurnFee.setBurnFeeRate(10); // Set burn fee to 10%
    }

    // New function to set the feeCollector address
    function setFeeCollector(address _feeCollector) public onlyRole(DEFAULT_ADMIN_ROLE) {
        feeCollector = _feeCollector;
    }

    // The mint function allows an account with the minter role to create new tokens and add them to the supply.
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // The grantMinterRole function allows an account with the default admin role to grant the minter role to another account.
    function grantMinterRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
    }

    // The _beforeTokenTransfer function is an internal function that is called before any transfer of tokens. It checks the blacklist, rate limiter, and maximum transfer amount.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Upgradeable) {
         require(!Blacklist.isBlacklisted(from) && !Blacklist.isBlacklisted(to), "Blacklisted address");
        super._beforeTokenTransfer(from, to, amount);
    }

    // The _afterTokenTransfer function is called after a successful token transfer. It updates the last transfer timestamp for the sender.
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override (ERC20Upgradeable){
    RateLimiter._afterTokenTransfer(from, to, amount);
    if (from != address(0) && to != address(0)) { // Not a minting or burning operation
        uint256 burnAmount = amount * BurnFee.getBurnFeeRate() / 100;
         _transfer(from, feeCollector, burnAmount);
    }
    }
}
