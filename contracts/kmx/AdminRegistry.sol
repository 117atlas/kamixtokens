pragma solidity >=0.4.10 <0.6.0;

contract AdminRegistry {
    struct Admin {
        mapping (address => bool) admins;
    }
}
