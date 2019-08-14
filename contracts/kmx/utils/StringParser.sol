pragma solidity >=0.4.10 <0.6.0;

library StringParser {
    function parseToUint256(string memory _str) internal pure returns(uint256, bool) {
        bool hasError = false;
        bytes memory b = bytes(_str);
        uint256 result = 0;
        uint256 oldResult = 0;
        for (uint256 i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (b[i] >= byte(uint8(48)) && b[i] <= byte(uint8(57))) {
                // store old value so we can check for overflows
                oldResult = result;
                result = result * 10 + (uint8(b[i]) - 48); // bytes and int are not compatible with the operator -.
                // prevent overflows
                if(oldResult > result ) {
                    // we can only get here if the result overflowed and is smaller than last stored value
                    hasError = true;
                }
            } else {
                hasError = true;
            }
        }
        return (result, hasError);
    }
}