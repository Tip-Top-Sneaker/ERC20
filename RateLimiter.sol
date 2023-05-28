// SPDX-License-Identifier: MIT
// RateLimiter.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// The RateLimiter contract limits the frequency of token transfers.
contract RateLimiter is Initializable, AccessControlUpgradeable {
    // Define a new role identifier for the rate manager.
    bytes32 public constant RATE_MGR = keccak256("RATE_MGR");

    // Define a mapping to store the timestamp of the last transfer for each address.
    mapping(address => uint256) private _lastTransferTimestamp;

    // Define the minimum time between transfers.
    uint256 public minTimeBetweenTransfers;

    // Define an event for updating the minimum time between transfers.
    event MinTimeBetweenTransfersUpdated(uint256 newMinTime);

    // In the initializer, set up the rate manager role and initial minimum time between transfers.
    function initialize() public virtual initializer {
        __AccessControl_init();
        _setupRole(RATE_MGR, msg.sender);
        minTimeBetweenTransfers = 30 minutes; // Set default minimum time between transfers to 30 minutes
    }

    // The setMinTimeBetweenTransfers function allows an account with the rate manager role to update the minimum time between transfers.
    function setMinTimeBetweenTransfers(uint256 newMinTime) public onlyRole(RATE_MGR) {
        minTimeBetweenTransfers = newMinTime;
        emit MinTimeBetweenTransfersUpdated(newMinTime);
    }

    // The _beforeTokenTransfer function is an internal function that is called before any transfer of tokens. It checks if the minimum time between transfers has passed.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        require(block.timestamp - _lastTransferTimestamp[from] >= minTimeBetweenTransfers, "Transfer frequency exceeded");
    }

    // The _afterTokenTransfer function is called after a successful token transfer. It updates the last transfer timestamp for the sender.
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual{
        _lastTransferTimestamp[from] = block.timestamp;
    }
}
