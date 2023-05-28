// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MaxTransfer is Initializable, AccessControlUpgradeable {
    bytes32 public constant TRANSFER_MGR = keccak256("TRANSFER_MGR");
    uint256 public maxTransferAmount;

    event MaxTransferAmountUpdated(uint256 newMaxAmount);

    function initialize(uint8 decimals) public initializer {
        __AccessControl_init();
        _setupRole(TRANSFER_MGR, msg.sender);
        maxTransferAmount = 50000 * (10 ** uint256(decimals)); // Set default maximum transfer amount to 50,000 tokens
    }

    function setMaxTransferAmount(uint256 newMaxAmount) public onlyRole(TRANSFER_MGR) {
        maxTransferAmount = newMaxAmount;
        emit MaxTransferAmountUpdated(newMaxAmount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        require(amount <= maxTransferAmount, "Transfer amount exceeds the max allowed");
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {
        // Add any logic to be executed after the token transfer
    }
}