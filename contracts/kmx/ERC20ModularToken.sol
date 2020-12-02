pragma solidity >=0.4.10 <0.6.0;

import "./ERC20.sol";
import "./AccountFrozenableToken.sol";
import "./utils/SafeMath.sol";

contract ERC20ModularToken is ERC20, AccountFrozenableToken {
    uint256 internal _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    using SafeMath for uint256;

    function _getBalance(address account) internal view returns(uint256) {
        return balances[account];
    }

    function _addBalance(address account, uint256 value) internal {
        balances[account] = balances[account].add(value);
    }

    function _subBalance(address account, uint256 value) internal {
        balances[account] = balances[account].sub(value);
    }

    function _setBalance(address account, uint256 value) internal {
        balances[account] = value;
    }

    function _getAllowance(address owner, address spender) internal view returns(uint256) {
        return allowances[owner][spender];
    }

    function _addAllowance(address owner, address spender, uint256 value) internal {
        allowances[owner][spender] = allowances[owner][spender].add(value);
    }

    function _subAllowance(address owner, address spender, uint256 value) internal {
        allowances[owner][spender] = allowances[owner][spender].sub(value);
    }

    function _setAllowance(address owner, address spender, uint256 value) internal {
        allowances[owner][spender] = value;
    }

    function _approveAllArgs(address owner, address spender, uint256 value) internal {
        _setAllowance(owner, spender, value);
        emit Approval(msg.sender, spender, value);
    }

    function _increaseAllowanceAllArgs(address owner, address spender, uint256 value) internal {
        _addAllowance(owner, spender, value);
        emit Approval(msg.sender, spender, _getAllowance(owner, spender));
    }

    function _decreaseAllowanceAllArgs(address owner, address spender, uint256 value) internal {
        _subAllowance(owner, spender, value);
        emit Approval(msg.sender, spender, _getAllowance(owner, spender));
    }

    function _transferAllArgs(address from, address to, uint256 value) internal {
        if (address(to)!=address(this)) _addBalance(to, value);
        if (address(from)!=address(this)) _subBalance(from, value);
        emit Transfer(from, to, value);
    }

    function _transferFromAllArgs(address from, address to, uint256 value, address spender) internal {
        if (address(to)!=address(this)) _addBalance(to, value);
        _subAllowance(from, spender, value);
        if (address(from)!=address(this)) _subBalance(from, value);
        emit Transfer(from, to, value);
    }

    function increaseAllowance(address spender, uint256 value) public {
        require(msg.sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _increaseAllowanceAllArgs(msg.sender, spender, value);
    }

    function decreaseAllowance(address spender, uint256 value) public {
        require(msg.sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _decreaseAllowanceAllArgs(msg.sender, spender, value);
    }

    function approve(address spender, uint256 value) public returns(bool) {
        require(msg.sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _approveAllArgs(msg.sender, spender, value);
        return true;
    }

    function approveFromAdmin(address sender, address spender, uint256 value) public onlyAdmin returns(bool){
        require(sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _approveAllArgs(sender, spender, value);
        return true;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _getBalance(account);
    }

    function allowance(address owner, address spender) public view returns(uint256) {
        return _getAllowance(owner, spender);
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function transferFrom(address to, address from, uint256 value) public returns(bool){
        _transferFromAllArgs(from, to, value, msg.sender);
    }

    function transfer(address to, uint256 value) public returns(bool){
        _transferAllArgs(msg.sender, to, value);
    }

}