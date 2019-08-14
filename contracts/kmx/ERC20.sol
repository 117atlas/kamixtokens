pragma solidity >=0.4.10 <0.6.0;

import "./ERC20Basic.sol";

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns(uint256);
    function transferFrom(address to, address from, uint256 value) public returns(bool);
    function approve(address spender, uint256 value) public returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}