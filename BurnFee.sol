// BurnFee.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract BurnFee is AccessControlUpgradeable {
    bytes32 public constant FEE_MGR = keccak256("FEE_MGR");
    uint256 public burnFeeRate; // 10%

    uint256[50] private __gap; // reserve space for future variable

    event BurnFeeRateUpdated(uint256 newRate);

    function initialize() public virtual initializer {
        __AccessControl_init();
        burnFeeRate = 10;
        _setupRole(FEE_MGR, msg.sender);
    }

    function setBurnFeeRate(uint256 newRate) public onlyRole(FEE_MGR) {
        require(newRate <= 1000, "Burn fee rate exceeds the maximum allowed");
        burnFeeRate = newRate;
        emit BurnFeeRateUpdated(newRate);
    }

    function getBurnFeeRate() public view returns (uint256) {
        return burnFeeRate;
    }
}
