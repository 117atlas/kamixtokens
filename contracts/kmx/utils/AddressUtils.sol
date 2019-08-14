pragma solidity >=0.4.10 <0.6.0;

library AddressUtils {
    function isContractAddress(address _address) internal view returns(bool) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
}