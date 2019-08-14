pragma solidity >=0.4.10 <0.6.0;

import "./KMXToken.sol";

contract KMX is KMXToken {
    string public name = "Kamix";
    string public symbols = "KMX";
    uint256 public decimals = 18;

    function setName(string calldata _name) external onlyOwner {
        require(bytes(_name).length != 0, "Name must not be empty");
        name = _name;
    }

    function setSymbols(string calldata _symbols) external onlyOwner {
        require(bytes(_symbols).length != 0, "Symbols must not be empty");
        symbols = _symbols;
    }
}