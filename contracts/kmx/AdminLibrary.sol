pragma solidity >=0.4.10 <0.6.0;

import "./AdminRegistry.sol";

library AdminLibrary {

    function add(AdminRegistry.Admin storage registry, address account) internal {
        require(!has(registry, account), "Account has already have admin role");
        registry.admins[account] = true;
    }

    function remove(AdminRegistry.Admin storage registry, address account) internal {
        require(has(registry, account), "Account has not have admin role");
        registry.admins[account] = false;
    }

    function has(AdminRegistry.Admin storage registry, address account) internal view returns (bool) {
        require(account != address(0), "Account must not be zero-address");
        return registry.admins[account];
    }
}
