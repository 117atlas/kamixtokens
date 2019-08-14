pragma solidity >=0.4.10 <0.6.0;

contract ERC20Basic {
    function totalSupply() public view returns(uint256);
    function balanceOf(address account) public view returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}