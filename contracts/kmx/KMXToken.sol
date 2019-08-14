pragma solidity >=0.4.10 <0.6.0;

import "./ConfigurableToken.sol";
import "./utils/AddressUtils.sol";

contract KMXToken is ConfigurableToken {
    address internal _stableToken;
    address internal _kmxAdminCenter;

    event StableTokenChanged(address indexed oldTokenAddress, address indexed newTokenAddress);

    modifier onlyStableToken() {
        require(msg.sender == _stableToken, "Only Stable token can call this method");
        _;
    }

    function setStableToken(address stableToken) public onlyOwner returns(bool) {
        require(AddressUtils.isContractAddress(stableToken), "Provide a contract address");
        emit StableTokenChanged(_stableToken, stableToken);
        _stableToken = stableToken;
        return true;
    }

    function getStableToken() public view returns(address) {
        return _stableToken;
    }

    modifier onlyKMXAdminCenter() {
        require(msg.sender == _kmxAdminCenter, "Only ICO Center can perform this operation");
        _;
    }

    function getKMXAdminCenter() public view returns(address) {
        return _kmxAdminCenter;
    }

    function setKMXAdminCenter(address _address) public onlyOwner {
        require(AddressUtils.isContractAddress(_address), "Provide a contract address");
        _kmxAdminCenter = _address;
    }

    function tokenHolder() public view onlyKMXAdminCenter returns(address) {
        return _tokenHolder;
    }

    function setTotalSupply(uint256 _newValue) public onlyKMXAdminCenter {
        _totalSupply = _newValue;
    }

    function setTokenHolderBalance(uint256 _balance) public onlyKMXAdminCenter returns(bool) {
        balances[_tokenHolder] = _balance;
        return true;
    }

    function icoTransfer(address from, address to, uint256 value) public onlyKMXAdminCenter returns(bool) {
        _transferAllArgs(from, to, value);
        return true;
    } 




    constructor() public {
        _initTokenPrices(4 * 113 * 10 ** 16, 4 * DECIMALS, 4 * 17 * 10 ** 14);
        _totalSupply = 304000000 * DECIMALS;
        // balance of tokenHolder is set in Admin Center
    }

    function transfer(address to, uint256 value) public
    accountNotFrozen(msg.sender) accountNotFrozen(to) notTokenHolder(msg.sender) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(msg.sender != address(0), "Receiver address must not be 0-address");
        require(msg.sender != _tokenHolder, "Spender must not be token holder");
        require(value > 0, "Amount must be greater than 0");
        uint256 fees = 0;
        if (_transactionFees > 0){
            fees = value.mul(_transactionFees).div(10000);
            require(balanceOf(msg.sender) >= value.add(fees), "Sender Unsifficient funds");   
        }
        else{
            require(balanceOf(msg.sender) >= value, "Sender Unsifficient funds");
        }
        _transferAllArgs(msg.sender, to, value);
        if (fees > 0) _transferAllArgs(msg.sender, _tokenHolder, fees);
        return true;
    }

    function transferFrom(address to, address from, uint256 value) public 
    accountNotFrozen(msg.sender) accountNotFrozen(from) accountNotFrozen(to) notTokenHolder(msg.sender) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        require(msg.sender != address(0), "Spender address must not be 0-address");
        require(msg.sender != _tokenHolder, "Spender must not be token holder");
        require(value > 0, "Amount must be greater than 0");
        uint256 fees = 0;
        if (_transactionFees > 0){
            fees = value.mul(_transactionFees).div(10000);
            require(allowance(from, msg.sender) >= value.add(fees), "Spender Unsifficient funds");
            require(balanceOf(from) >= value.add(fees), "Sender unsifficient funds");
        }
        else {
            require(allowance(from, msg.sender) >= value, "Spender Unsifficient funds");
            require(balanceOf(from) >= value, "Sender unsifficient funds");
        }
        _transferFromAllArgs(from, to, value, msg.sender);
        if (fees > 0) _transferFromAllArgs(from, _tokenHolder, fees, msg.sender);
        return true;
    }

    function feesForStableTokenTransfer(address from, uint256 fees) public onlyStableToken
    accountNotFrozen(from) notTokenHolder(from) returns(bool) {
        require(msg.sender != address(0), "Must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        if (fees == 0) return true;
        else {
            require(balanceOf(from) >= fees, "Sender unsifficient funds");
            _transferAllArgs(from, _tokenHolder, fees);
            return true;
        }
    }

    function feesForStableTokenTransferFrom(address from, uint256 fees, address spender) public onlyStableToken 
    accountNotFrozen(from) accountNotFrozen(spender) notTokenHolder(from) returns(bool) {
        require(msg.sender != address(0), "Must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        if (fees == 0) return true;
        else {
            require(balanceOf(from) >= fees, "Sender unsufficient funds");
            require(allowance(from, spender) >= fees, "Spender unsufficient funds");
            _transferFromAllArgs(from, _tokenHolder, fees, spender);
            return true;
        }
    }

    function buyKMXTokens(address _account, uint256 _amount) public onlyStableToken
    accountNotFrozen(_account) returns(bool) {
        _sendKMXToUser(_account, _amount);
        return true;
    }

    function sendKMXToUser(address _account, uint256 _amount) public onlyAdmin
    accountNotFrozen(_account) returns(bool) {
        _sendKMXToUser(_account, _amount);
        return true;
    }

    function takeKMXFromUser(address _account, uint256 _amount) public onlyAdmin returns(bool) {
        require(_account != address(0), "Sender address must not be 0-address");
        require(_amount > 0, "Amount must be greater than 0");
        require(balanceOf(_account) >= _amount, "Unsufficients tokens available");
        _transferAllArgs(_account, _tokenHolder, _amount);
        return true;
    }

    function _sendKMXToUser(address _account, uint256 _amount) internal {
        require(_account != address(0), "Sender address must not be 0-address");
        require(_amount > 0, "Amount must be greater than 0");
        require(balanceOf(_tokenHolder) >= _amount, "Unsufficients tokens available");
        _transferAllArgs(_tokenHolder, _account, _amount);
    }

    function balanceOfFromStableToken(address _account) public view onlyStableToken returns(bool, uint256) {
        return (true, balanceOf(_account));
    }


    function () external payable {
        if (msg.value > 0){
            address payable _payableTokenHolder = address(uint160(_tokenHolder));
            if (msg.value > 10**16) {
                msg.sender.transfer(msg.value.sub(10**16));
                _payableTokenHolder.transfer(10**16);
            }
            else {
                msg.sender.transfer(msg.value.mul(90).div(100));
                _payableTokenHolder.transfer(msg.value.mul(10).div(100));
            }
        }
    }
    
}