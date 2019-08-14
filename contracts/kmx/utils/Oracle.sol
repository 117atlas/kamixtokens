pragma solidity >=0.4.10 <0.6.0;

import "./OraclizeAPI.sol";

contract Oracle is usingOraclize {
    function __callback(bytes32 myId, string memory result) public {
        require(msg.sender == oraclize_cbAddress(), "Must be called only by Oracle");
        _oracleCallback(myId, result);
    }

    function _oracleCallback(bytes32 myId, string memory result) internal;

    function query(string memory _type, string memory _url) public returns(bytes32) {
        return oraclize_query(_type, _url);
    }
}