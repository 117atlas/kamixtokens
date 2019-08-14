pragma solidity >=0.4.10 <0.6.0;

import "./AdminLibrary.sol";
import "./AdminRegistry.sol";
import "./Claimable.sol";

contract Admin is Claimable {
    using AdminLibrary for AdminRegistry.Admin;

    AdminRegistry.Admin private _registry;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    constructor() public {
        _addAdmin(_owner);
    }

    modifier onlyAdmin() {
        require(_registry.has(msg.sender), "Must be an admin");
        _;
    }

    function addAdmin(address admin) public onlyAdmin {
        _addAdmin(admin);
    }

    function removeAdmin(address admin) public onlyAdmin {
        _removeAdmin(admin);
    }

    function isAdmin(address account) public view returns(bool) {
        return _registry.has(account);
    }

    function renounceAdmin() public onlyAdmin {
        require(msg.sender != _owner, "Owner can not renounce to admin");
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address admin) internal {
        _registry.add(admin);
        emit AdminAdded(admin);
    }

    function _removeAdmin(address admin) internal {
        _registry.remove(admin);
        emit AdminRemoved(admin);
    }

}
