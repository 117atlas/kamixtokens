pragma solidity >=0.4.10 <0.6.0;

import "./KMXStableToken.sol";
import "./KMXStableMarketLib.sol";
import "./utils/Oracle.sol";
import "./utils/AddressUtils.sol";
import "./utils/SafeMath.sol";
import "./utils/StringParser.sol";

library SafeKMXStableTokenForMarket {
    function safeMarketTransfer(KMXStableToken kmxStableToken, address from, address to, uint256 value) internal returns(bool){
        assert(kmxStableToken.marketTransfer(from, to, value));
        return true;
    }
    function safeBuyKMX(KMXStableToken kmxStableToken, address account, uint256 tknQty) internal returns(bool) {
        assert(kmxStableToken.marketBuyKMX(account, tknQty));
        return true;
    }
}

contract KMXStableMarket is Oracle {
    event TokenBought(address indexed account, uint256 tknAmount);
    event TokenRefunded(address indexed account, uint256 tknAmount);
    event KMXTokensBought(address indexed buyer, uint256 amount);

    address internal _kmxStableTokenAddress;
    KMXStableToken internal _kmxStableToken;
    KMXStableMarketLib.KMXMarketData internal _marketData;
    
    string internal _stableTokenPriceUrl;
    uint256 internal _buyKMXFees;

    using AddressUtils for address;
    using SafeMath for uint256;
    using StringParser for string;
    using SafeKMXStableTokenForMarket for KMXStableToken;

    constructor(address _kmxStbTknAdd) public payable {
        require(_kmxStbTknAdd.isContractAddress(), "Provide contract addresses");
        address payable _payableKmxStbTknAdd = address(uint160(_kmxStbTknAdd));
        _kmxStableToken = KMXStableToken(_payableKmxStbTknAdd);
        _kmxStableTokenAddress = _kmxStbTknAdd;
        _buyKMXFees = 100;
    }

    function setStableTokenPriceUrl(string memory newUrl) public onlyAdmin {
        _stableTokenPriceUrl = newUrl;
    }

    function stableTokenPriceUrl() public view returns(string memory){
        return _stableTokenPriceUrl;
    }

    function setBuyKMXFees(uint256 _newBuyKMXFees) public onlyAdmin {
        require(_newBuyKMXFees <=10000, "Fees must be in percentage");
        _buyKMXFees = _newBuyKMXFees;
    }

    function buyKMXFees() public view returns(uint256) {
        return _buyKMXFees;
    }

    function setKMXStableToken(address _address) public onlyOwner {
        require(_address.isContractAddress(), "Provide contract address");
        address payable _payableKmxStbTknAdd = address(uint160(_address));
        _kmxStableToken = KMXStableToken(_payableKmxStbTknAdd);
        _kmxStableTokenAddress = _address;
    }

    function kmxStableToken() public view returns(address) {
        return _kmxStableTokenAddress;
    }

    modifier onlyAdmin() {
        require(_kmxStableToken.isAdmin(msg.sender), "Only Admin can perform this operation");
        _;
    }

    modifier onlyOwner() {
        require(_kmxStableToken.isOwner(msg.sender), "Only owner can perform this operation");
        _;
    }

    modifier onlySeller(address _seller) {
        require(isSeller(_seller), "Must be an token seller");
        _;
    }

    modifier sellerOrAdmin() {
        require(msg.sender != address(0) && (isSeller(msg.sender) || _kmxStableToken.isAdmin(msg.sender)),
                "Only sellers or admins can perform this operation");
        _;
    }

    modifier validateBuyRefParams(address _address, uint256 _amt) {
        require(_address != address(0), "Account address must not be 0-address");
        require(_address != _kmxStableToken.tokenHolder(), "Account must not be token holder");
        require(!_kmxStableToken.isAccountFrozen(_address), "Account is frozen");
        require(_amt > 0, "Amount of currency / Tokens quantity given must be greater than 0");
        _;
    }

    modifier validCurrency(string memory _currency) {
        require(_kmxStableToken.validCurrency(_currency), "Provide a valid currency");
        _;
    }
 
    function isSeller(address _seller) public view returns(bool) {
        return KMXStableMarketLib.isSeller(_marketData, _seller);
    }

    function addSeller(address _seller) public onlyAdmin {
        require(_seller != address(0), "Seller Address must not be 0-address");
        require(_seller != _kmxStableToken.tokenHolder(), "Seller must not be token holder");
        require(!isSeller(_seller), "Already a seller");
        KMXStableMarketLib.addSeller(_marketData, _seller);
    }

    function removeSeller(address _seller) public onlyAdmin {
        require(isSeller(_seller), "Is not a seller");
        KMXStableMarketLib.removeSeller(_marketData, _seller);
    }

    function buy(address _account, string memory _currency, uint256 _amount) public
    sellerOrAdmin validCurrency(_currency) validateBuyRefParams(_account, _amount) returns(uint256) {
        if (isSeller(_account)){
            require(_kmxStableToken.isAdmin(msg.sender), "Only admin can perform this operation for sellers");
        }
        (uint256 tknQty, uint256 rfd) = KMXStableMarketLib.buy(_kmxStableToken.tokenPrice(_currency), _amount, _kmxStableToken.balanceOf(_kmxStableToken.tokenHolder()));
        if (tknQty > 0){
            _kmxStableToken.safeMarketTransfer(_kmxStableToken.tokenHolder(), _account, tknQty);
            emit TokenBought(_account, tknQty);
        }
        return rfd;
    }

    function buyFromSeller(address _account, string memory _currency, uint256 _amount) public
    onlySeller(msg.sender) validCurrency(_currency) validateBuyRefParams(_account, _amount) returns(uint256) {
        (uint256 tknQty, uint256 rfd) = KMXStableMarketLib.buy(_kmxStableToken.tokenPrice(_currency), _amount, _kmxStableToken.balanceOf(msg.sender));
        if (tknQty > 0){
            _kmxStableToken.safeMarketTransfer(msg.sender, _account, tknQty);
            emit TokenBought(_account, tknQty);
        }
        return rfd;
    }

    function refundAmount(address _account, string memory _currency, uint256 _tokenQuantity) public view
    sellerOrAdmin validCurrency(_currency) validateBuyRefParams(_account, _tokenQuantity) returns(uint256) {
        return KMXStableMarketLib.refundAmount(_kmxStableToken.tokenPrice(_currency), _tokenQuantity);
    }

    function refund(address _account, string memory _currency, uint256 _tokenQuantity) public
    sellerOrAdmin validCurrency(_currency) validateBuyRefParams(_account, _tokenQuantity) returns(bool) {
        if (isSeller(_account)){
            require(_kmxStableToken.isAdmin(msg.sender), "Only admin can perform this operation for sellers");
        }
        require(_kmxStableToken.balanceOf(_account) >= _tokenQuantity, "Unsufficient funds");
        _kmxStableToken.safeMarketTransfer(_account, _kmxStableToken.tokenHolder(), _tokenQuantity);
        emit TokenRefunded(_account, _tokenQuantity);
        return true;
    }

    function refundToSeller(address _account, string memory _currency, uint256 _tokenQuantity) public
    onlySeller(msg.sender) validCurrency(_currency) validateBuyRefParams(_account, _tokenQuantity) returns(bool) {
        require(_kmxStableToken.balanceOf(_account) >= _tokenQuantity, "Unsufficient funds");
        _kmxStableToken.safeMarketTransfer(_account, msg.sender, _tokenQuantity);
        emit TokenRefunded(_account, _tokenQuantity);
        return true;
    }

    function buyKMXTokens(uint256 _amount) public {
        KMXStableMarketLib.buyKMXTokens(_marketData, _amount, msg.sender, _kmxStableToken.balanceOf(msg.sender), this, _stableTokenPriceUrl);
    }

    function exchangeKMXTokens(bytes32 _oracleReqId, uint256 stableTokenPrice) internal { // 1 KMX ===? x KEUR
        address _account = _marketData.buyKMXBuyersReqIds[_oracleReqId];
        (uint256 tknQty, uint256 fees) = KMXStableMarketLib.exchangeKMXTokens(_marketData, _oracleReqId, stableTokenPrice, _buyKMXFees, _kmxStableToken.balanceOf(_account));
        if (tknQty > 0) {
            _kmxStableToken.safeBuyKMX(_account, tknQty);
            emit KMXTokensBought(_account, tknQty);
        }
        if (fees > 0) {
            _kmxStableToken.safeMarketTransfer(_account, _kmxStableToken.tokenHolder(), fees);
        }
    }

    function _oracleCallback(bytes32 myId, string memory result) internal {
        if (_marketData.buyKMXBuyersReqIds[myId]!=address(0)){
            (uint256 stTknPrice, bool error) = result.parseToUint256();
            exchangeKMXTokens(myId, error?0:stTknPrice);
        }
    }

    function kill() public onlyOwner {
        address payable _payableOwner = address(uint160(msg.sender));
        selfdestruct(_payableOwner);
    }

    function () external payable {
        if (msg.value > 0){
            address payable _payableTokenHolder = address(uint160(_kmxStableToken.tokenHolder()));
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