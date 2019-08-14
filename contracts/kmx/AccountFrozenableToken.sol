pragma solidity >=0.4.10 <0.6.0;

import "./Admin.sol";

contract AccountFrozenableToken is Admin {
    mapping(address => bool) frozenAccounts;

    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);

    function _isAccountFrozen(address _account) internal view returns(bool) {
        return frozenAccounts[_account];
    }

    modifier accountFrozen(address _account) {
        require(_isAccountFrozen(_account), "Account must be frozen");
        _;
    }

    modifier accountNotFrozen(address _account) {
        require(!_isAccountFrozen(_account), "Account must not be frozen");
        _;
    }

    function isAccountFrozen(address _account) public view returns(bool) {
        return _isAccountFrozen(_account);
    }

    function frozeAccount(address _account) public onlyAdmin accountNotFrozen(_account) {
        frozenAccounts[_account] = true;
        emit AccountFrozen(_account);
    }

    function unfrozeAccount(address _account) public onlyAdmin accountFrozen(_account) {
        frozenAccounts[_account] = false;
        emit AccountUnfrozen(_account);
    }
}