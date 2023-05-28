// SPDX-License-Identifier: MIT
// MaxTransfer.sol
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

    function getMaxTransferAmount() public view returns (uint256) {
        return maxTransferAmount;
    }


}
