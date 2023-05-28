// Blacklist.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Blacklist is AccessControlUpgradeable {
    bytes32 public constant LIST_MGR = keccak256("LIST_MGR");
    mapping(address => bool) private _blacklist;

    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
    event ListMgrRoleGranted(address indexed account);
    event ListMgrRoleRevoked(address indexed account);

    constructor() {
        _setupRole(LIST_MGR, msg.sender);
    }



    function blacklist(address account) public onlyRole(LIST_MGR) {
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    function unblacklist(address account) public onlyRole(LIST_MGR) {
        _blacklist[account] = false;
        emit Unblacklisted(account);
    }

    function grantListMgrRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(LIST_MGR, account);
        emit ListMgrRoleGranted(account);
    }

    function revokeListMgrRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(LIST_MGR, account);
        emit ListMgrRoleRevoked(account);
    }

    // The isBlacklisted function allows to check if an address is blacklisted.
    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account];
    }
}
