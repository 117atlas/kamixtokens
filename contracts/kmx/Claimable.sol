pragma solidity >=0.4.10 <0.6.0;

import "./Ownable.sol";
contract Claimable is Ownable {
    address internal _pendingOwner;

    modifier onlyPendingOwner(){
        require(msg.sender==_pendingOwner, "Sender must be pending owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner!=address(0), "Owner address must not be 0-address");
        _pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {
        _owner = _pendingOwner;
        emit OwnershipTransferred(_owner, _pendingOwner);
    }
}