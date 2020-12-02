pragma solidity >=0.4.10 <0.6.0;

import "./MintBurnToken.sol";
import "./KMXToken.sol";
import "./utils/AddressUtils.sol";

library SafeKMXToken {
    function SafeFeesForStableTokenTransfer(KMXToken token, address from, uint256 fees) internal returns(bool) {
        assert(token.feesForStableTokenTransfer(from, fees));
        return true;
    }
    function SafeFeesForStableTokenTransferFrom(KMXToken token, address from, uint256 fees, address spender) internal returns(bool) {
        assert(token.feesForStableTokenTransferFrom(from, fees, spender));
        return true;
    }
    function SafeBuyKMXTokens(KMXToken token, address account, uint256 amount) internal returns(bool) {
        assert(token.buyKMXTokens(account, amount));
        return true;
    }
    function SafeBalanceOf(KMXToken token, address account) internal view returns(uint256) {
        bool success = false;
        uint256 balance = 0;
        (success, balance) = token.balanceOfFromStableToken(account);
        assert(success);
        return balance;
    }
}

contract KMXStableToken is MintBurnToken {
    address internal _kmxStableMarketAddress;
    KMXToken internal _kmxToken;
    address internal _kmxTokenAdd;
    uint256 internal _kmxTokenDiscountForFees;

    event KMXTokenSet(address indexed tokenAddress);

    using SafeKMXToken for KMXToken;

    constructor() public {
        _initTokenPrices(1 * 113 * 10 ** 16, 1 * DECIMALS, 1 * 17 * 10 ** 14);
        _kmxTokenDiscountForFees = 50;
        _totalSupply = 10000000 * DECIMALS;
        balances[_tokenHolder] = _totalSupply;
    }

    function changeKmxTokenDiscountForFees(uint256 kmxTokenDiscountForFees) public onlyOwner {
        require(kmxTokenDiscountForFees<=100, "Fees Discount using KMX Token for KMX Stable Tokens must be between 0 and 100 %");
        _kmxTokenDiscountForFees = kmxTokenDiscountForFees;
    }

    function getKmxTokenDiscountForFees() public view returns(uint256){
        return _kmxTokenDiscountForFees;
    }

    modifier isContractAddress(address _address) {
        require(AddressUtils.isContractAddress(_address), "Must be a contract address");
        _;
    }

    modifier onlyMarketContract() {
        require(msg.sender == _kmxStableMarketAddress, "Only Market contract can perform this operation");
        _;
    }

    function tokenHolder() public view onlyMarketContract returns(address) {
        return _tokenHolder;
    }

    function setKmxToken(address _address) public isContractAddress(_address) onlyOwner returns(bool) {
        address payable _payableAddress = address(uint160(_address));
        _kmxToken = KMXToken(_payableAddress);
        _kmxTokenAdd = _address;
        emit KMXTokenSet(_kmxTokenAdd);
        return true;
    }

    function getKmxToken() public view returns(address) {
        return _kmxTokenAdd;
    }

    function setMarketContractAddress(address _address) public isContractAddress(_address) onlyOwner  {
        _kmxStableMarketAddress = _address;
    }

    function marketContractAddress() public view returns(address) {
        return _kmxStableMarketAddress;
    }

    function kmxStableTokenTransfer(address to, uint256 value) public 
    accountNotFrozen(msg.sender) accountNotFrozen(to) notTokenHolder(msg.sender) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(msg.sender != address(0), "Receiver address must not be 0-address");
        require(value > 0, "Amount must be greater than 0");
        if (_transactionFees > 0) {
            uint256 fees = value.mul(_transactionFees).div(10000);
            require(balanceOf(msg.sender) >= value.add(fees), "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
            _transferAllArgs(msg.sender, _tokenHolder, fees);
        }
        else {
            require(balanceOf(msg.sender) >= value, "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
        }
        return true;
    }

    function kmxStableTokenTransferFrom(address from, address to, uint256 value) public 
    accountNotFrozen(msg.sender) accountNotFrozen(from) accountNotFrozen(to) notTokenHolder(from) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        require(msg.sender != address(0), "Spender address must not be 0-address");
        require(value > 0, "Amount must be greater than 0");
        if (_transactionFees > 0) {
            uint256 fees = value.mul(_transactionFees).div(10000);
            require(balanceOf(from) >= value.add(fees), "Sender unsufficient funds");
            require(allowance(from, msg.sender) >= value.add(fees), "Spender unsufficient fees");
            _transferFromAllArgs(from, to, value, msg.sender);
            _transferFromAllArgs(from, _tokenHolder, fees, msg.sender);
        }
        else{
            require(balanceOf(from) >= value, "Sender unsufficient funds");
            require(allowance(from, msg.sender) >= value, "Spender unsufficient fees");
            _transferFromAllArgs(from, to, value, msg.sender);
        } 
        return true;
    }

    function kmxStableTokenTransferKMXFees(address to, uint256 value, uint256 stableTokenPrice) public 
    accountNotFrozen(msg.sender) accountNotFrozen(to) notTokenHolder(msg.sender) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(msg.sender != address(0), "Receiver address must not be 0-address");
        require(value > 0, "Amount must be greater than 0");
        if (_transactionFees > 0) {
            uint256 fees = value.mul(_transactionFees).div(10000);
            fees = fees.mul(DECIMALS).div(stableTokenPrice);
            fees = fees.mul(uint256(100).sub(_kmxTokenDiscountForFees)).div(100);
            require(balanceOf(msg.sender) >= value, "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
            return _kmxToken.SafeFeesForStableTokenTransfer(msg.sender, fees);
        }
        else {
            require(balanceOf(msg.sender) >= value, "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
        }
        return true;
    }

    function kmxStableTokenTransferFromKMXFees(address from, address to, uint256 value, uint256 stableTokenPrice) public
    accountNotFrozen(msg.sender) accountNotFrozen(from) accountNotFrozen(to) notTokenHolder(from) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        require(msg.sender != address(0), "Spender address must not be 0-address");
        require(value > 0, "Amount must be greater than 0");
        if (_transactionFees > 0) {
            uint256 fees = value.mul(_transactionFees).div(10000);
            fees = fees.mul(DECIMALS).div(stableTokenPrice);
            fees = fees.mul(uint256(100).sub(_kmxTokenDiscountForFees)).div(100);
            require(balanceOf(from) >= value, "Sender unsufficient funds");
            require(allowance(from, msg.sender) >= value, "Spender unsufficient fees");
            _transferFromAllArgs(from, to, value, msg.sender);
            return _kmxToken.SafeFeesForStableTokenTransferFrom(from, fees, msg.sender);
        }
        else{
            require(balanceOf(from) >= value, "Sender unsufficient funds");
            require(allowance(from, msg.sender) >= value, "Spender unsufficient fees");
            _transferFromAllArgs(from, to, value, msg.sender);
        } 
        return true;
    }

    function transfer(address to, uint256 value) public returns(bool) {
        return kmxStableTokenTransfer(to, value);
    }

    function transferFrom(address to, address from, uint256 value) public returns(bool) {
        return kmxStableTokenTransferFrom(from, to, value);
    }

    function marketTransfer(address from, address to, uint256 value) public onlyMarketContract returns(bool) {
        _transferAllArgs(from, to, value);
        return true;
    }

    function marketBuyKMX(address to, uint256 value) public onlyMarketContract returns(bool) {
        _kmxToken.SafeBuyKMXTokens(to, value);
        return true;
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

    /*function buyKMXTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Unsufficient balances");
        bytes32 reqId = oraclize_query("URL", string(abi.encodePacked("json(", _stableTokenPriceUrl, ").price")));
        buyKMXBuyersReqIds[reqId] = msg.sender;
        buyKMXBuyers[msg.sender] = amount;
        requestBuyKMXTokens[msg.sender] = true;
    }

    function exchangeKMXTokens(bytes32 _oracleReqId, uint256 stableTokenPrice) public { // 1 KMX ===? x KEUR
        address _account = buyKMXBuyersReqIds[_oracleReqId];
        uint256 amount = buyKMXBuyers[_account];
        uint256 fees = amount.mul(_buyKMXFees).div(100);
        if (!requestBuyKMXTokens[msg.sender]){
            emit FeedbackBuyKMX(_account, "Sender has not requested buy KMX Tokens");
            delete buyKMXBuyersReqIds[_oracleReqId];
            delete buyKMXBuyers[_account];
            requestBuyKMXTokens[msg.sender] = false;
        }
        else if (balanceOf(msg.sender) < amount){
            emit FeedbackBuyKMX(_account, "Unsufficient balances");
            delete buyKMXBuyersReqIds[_oracleReqId];
            delete buyKMXBuyers[_account];
            requestBuyKMXTokens[msg.sender] = false;
        }
        else{
            uint256 amountToUse = amount.sub(fees);
            uint256 kmxTokensQuantity = amountToUse.mul(DECIMALS).div(stableTokenPrice);
            _kmxToken.SafeBuyKMXTokens(msg.sender, kmxTokensQuantity);
            _transferAllArgs(_account, _tokenHolder, fees);
            emit KMXTokensBought(msg.sender, kmxTokensQuantity);
        }
    }

    function _oracleCallback(bytes32 myId, string memory result) internal {
        //super._oracleCallback(myId, result);
        if (buyKMXBuyersReqIds[myId]!=address(0)){
            (uint256 stTknPrice, bool error) = result.parseToUint256();
            exchangeKMXTokens(myId, error?0:stTknPrice);
        }
    }*/

}