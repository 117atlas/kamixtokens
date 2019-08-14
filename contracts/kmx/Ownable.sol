pragma solidity >=0.4.10 <0.6.0;

contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        require(msg.sender!=address(0), "Owner address must not be 0-address");
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==_owner, "This is not contract owner");
        _;
    }

    function isOwner(address _address) public view returns(bool) {
        return _owner == _address;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner!=address(0), "Owner address must not be 0-address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function kill() public onlyOwner {
        address payable _payableOwner = address(uint160(_owner));
        selfdestruct(_payableOwner);
    }
}