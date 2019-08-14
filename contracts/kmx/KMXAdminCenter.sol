pragma solidity >=0.4.10 <0.6.0;

import "./KMXToken.sol";
import "./utils/AddressUtils.sol";
import "./utils/SafeMath.sol";
import "./utils/StringParser.sol";
import "./utils/Oracle.sol";
import "./KMXLibrary.sol"; 

library SafeKMXTokenForAdmin {
    function safeIcoTransfer(KMXToken kmxToken, address from, address to, uint256 value) internal returns(bool) {
        assert(kmxToken.icoTransfer(from, to, value));
        return true;
    }    
    function safeSetTokenHolderBalance(KMXToken kmxToken, uint256 balance) internal returns(bool) {
        assert(kmxToken.setTokenHolderBalance(balance));
        return true;
    }   
}

contract KMXAdminCenter is Oracle {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event ICOTokenBought(address indexed buyer, uint256 value);
    event ICOTokenRefunded(address indexed refunder, uint256 value); 

    KMXLibrary.ICOParams internal _icoParams;
    KMXLibrary.KMXTokenParts _kmxTokenParts;

    string public _tknEtherPriceOracleUrl;
    uint256 public _buyRefundWithEtherFees;

    address internal _kmxTokenAddress;
    KMXToken internal _kmxToken;

    uint256 internal constant DECIMALS = 10**18;

    bool private initialized = false;

    using AddressUtils for address;
    using SafeMath for uint256;
    using StringParser for string;
    using SafeKMXTokenForAdmin for KMXToken;

    modifier onlyAdmin() {
        require(_kmxToken.isAdmin(msg.sender), "Only Admin can perform this operation");
        _;
    }

    modifier onlyOwner() {
        require(_kmxToken.isOwner(msg.sender), "Only Owner can perform this operation");
        _;
    }

    constructor() public payable {

    }

    function initAdminCenter(address _address) public {
        require(!initialized, "Already initialized");
        require(_address.isContractAddress(), "Address must be contract address");
        address payable _payableAddress = address(uint160(_address));
        _kmxToken = KMXToken(_payableAddress);
        _kmxTokenAddress = _address;

        _kmxTokenParts._tokensToSell = 99000000 * DECIMALS; //100 m
        _kmxTokenParts._reserveTokens = 60000000 * DECIMALS;
        _kmxTokenParts._circulatingTokens = 145000000 * DECIMALS; //144 m
        _kmxToken.setTokenHolderBalance(_kmxTokenParts._circulatingTokens);

        KMXLibrary.init(_icoParams, _kmxTokenParts);

        _buyRefundWithEtherFees = 10 * 10 ** 15;

        initialized = true;
    }

    modifier validateBuyRefICO(address _account) {
        require(_account != address(0), "Account address must not be 0-address");
        require(_account != _kmxToken.tokenHolder(), "Account address must not be token holder account");
        require(!_kmxToken.isAccountFrozen(_account), "Account is frozen");
        require(_icoParams._icoState == KMXLibrary.ICOState.ICO_ONGOING, "ICO Must be ongoing status");
        _;
    }

    modifier validCurrency(string memory _currency) {
        require(_kmxToken.validCurrency(_currency), "Provide a valid currency");
        _;
    }

    modifier acceptEther() {
        require(_icoParams._buyWithEther, "Buy tokens with ether not allowed");
        _;
    }

    function enableBuyWithEther() public onlyOwner {
        KMXLibrary.enableBuyWithEther(_icoParams);
    }

    function disableBuyWithEther() public onlyOwner {
        KMXLibrary.enableBuyWithEther(_icoParams);
    }

    function isEtherAccepted() public view returns(bool) {
        return _icoParams._buyWithEther;
    }

    function startIco() public onlyOwner {
        KMXLibrary.startICO(_icoParams);
    }

    function pauseIco() public onlyOwner {
        KMXLibrary.pauseICO(_icoParams);
    }

    function continueIco() public onlyOwner {
        KMXLibrary.continueICO(_icoParams);
    }

    function endIco() public onlyOwner {
        KMXLibrary.endICO(_icoParams, _kmxTokenParts);
        address payable _payableTknHolder = address(uint160(_kmxToken.tokenHolder()));
        _payableTknHolder.transfer(address(this).balance);
    }

    function statusIco() public view returns(string memory) {
        return KMXLibrary.statusICO(_icoParams);
    }

    function tokens(uint8 part) public view onlyAdmin returns(uint256) {
        return KMXLibrary.tokensPart(_icoParams, _kmxTokenParts, part);
    }

    function reserveToSell(uint256 _amount) public onlyAdmin {
        KMXLibrary.reserveToSell(_icoParams, _kmxTokenParts, _amount);
    }

    function sellToReserve(uint256 _amount) public onlyAdmin {
        KMXLibrary.sellToReserve(_icoParams, _kmxTokenParts, _amount);
    }

    function sellToCirculation(uint256 _amount) public onlyAdmin {
        KMXLibrary.sellToCirculation(_icoParams, _kmxTokenParts, _amount);
        _kmxToken.safeSetTokenHolderBalance(_kmxTokenParts._circulatingTokens);
    }

    function circulationToSell(uint256 _amount) public onlyAdmin {
        KMXLibrary.circulationToSell(_icoParams, _kmxTokenParts, _amount, _kmxToken.balanceOf(_kmxToken.tokenHolder()));
        _kmxToken.safeSetTokenHolderBalance(_kmxTokenParts._circulatingTokens);
    }

    function reserveToCirculation(uint256 _amount) public onlyAdmin {
        KMXLibrary.reserveToCirculation(_kmxTokenParts, _amount);
        _kmxToken.safeSetTokenHolderBalance(_kmxTokenParts._circulatingTokens);
    }

    function circulationToReserve(uint256 _amount) public onlyOwner {
        KMXLibrary.circulationToReserve(_kmxTokenParts, _amount, _kmxToken.balanceOf(_kmxToken.tokenHolder()));
        _kmxToken.safeSetTokenHolderBalance(_kmxTokenParts._circulatingTokens);
    }

    function changeTokenEthPriceOracleUrl(string memory newUrl) public onlyAdmin {
        _tknEtherPriceOracleUrl = newUrl;
    }

    function changeBuyRefundWithEtherFees(uint256 _newEthFees) public onlyAdmin {
        _buyRefundWithEtherFees = _newEthFees;
    }

    function buyICOTokensForAccount(address _account, string memory _currency, uint256 _amount) public 
    onlyAdmin validateBuyRefICO(_account) validCurrency(_currency) returns(uint256) {
        (uint256 tknQty, uint256 rfd) = KMXLibrary.buyICOTokensForAccount(_icoParams, _kmxToken.tokenPrice(_currency), _amount);
        if (tknQty > 0) {
            _kmxToken.safeIcoTransfer(_kmxTokenAddress, _account, tknQty);
            KMXLibrary.notifyTokensBought(_icoParams, tknQty, _account);
            KMXLibrary.increaseTokensSold(_icoParams, tknQty);
        }
        return rfd;
    }

    function refundICOAmount(address _account, string memory _currency, uint256 _tokenQuantity) public view
    onlyAdmin validateBuyRefICO(_account) validCurrency(_currency) returns(uint256) {
        return KMXLibrary.refundICOAmount(_kmxToken.tokenPrice(_currency), _tokenQuantity);
    }

    function refundICO(address _account, string memory _currency, uint256 _tokenQuantity) public
    onlyAdmin validateBuyRefICO(_account) validCurrency(_currency) returns(uint256) {
        if (KMXLibrary.refundICO(_icoParams, _account, _tokenQuantity)){    
            _kmxToken.safeIcoTransfer(_account, _kmxTokenAddress, _tokenQuantity);
            KMXLibrary.notifyRefund(_icoParams, _tokenQuantity, _account);
            KMXLibrary.decreaseTokensSold(_icoParams, _tokenQuantity);
        }
    }

    function buyICOTokensWithEther() public payable acceptEther validateBuyRefICO(msg.sender) {
        if (!KMXLibrary.buyICOTokensWithEther(_icoParams, msg.sender, msg.value, this, _buyRefundWithEtherFees, _tknEtherPriceOracleUrl)){
            msg.sender.transfer(_icoParams.pendingEtherICOBuyers[msg.sender]);
            emit Transfer(address(this), msg.sender, _icoParams.pendingEtherICOBuyers[msg.sender]);
        }
    }

    function () external {
        buyICOTokensWithEther();
    }

    function buyICOTokenWithEtherEnd(bytes32 _oracleReqId, uint256 _tknPrice) internal {
        (bool fb, uint256 tknQty, uint256 rfd, address _account, uint256 _ethAmt) = KMXLibrary.buyICOTokenWithEtherEnd(_icoParams, _buyRefundWithEtherFees, _oracleReqId, _tknPrice);
        if (!fb){
            address payable _payableAccount = address(uint160(_account));
            _payableAccount.transfer(_ethAmt);
            emit Transfer(address(this), _account, _ethAmt);
        }
        else{
            if (tknQty > 0){
                _kmxToken.safeIcoTransfer(_kmxTokenAddress, _account, tknQty);
                KMXLibrary.notifyTokensBought(_icoParams, tknQty, _account);
                KMXLibrary.notifyTokensBoughtWithEther(_icoParams, _account);
                KMXLibrary.increaseTokensSold(_icoParams, tknQty);
                emit ICOTokenBought(_account, tknQty);
            }
            if (rfd > 0){
                address payable _payableAccount = address(uint160(_account));
                _payableAccount.transfer(rfd);
                emit Transfer(address(this), _account, rfd);
            }
        }
    } 

    function refundICOTokenWithEther(uint256 _tokenQuantity) public validateBuyRefICO(msg.sender) {
        KMXLibrary.refundICOTokenWithEther(_icoParams, msg.sender, _tokenQuantity, this, _tknEtherPriceOracleUrl);
    }

    function refundICOTokenWithEtherEnd(bytes32 _oracleReqId, uint256 _tknPrice) internal {
        address _account = _icoParams.pendingEtherICOBuyersReqIds[_oracleReqId];
        (uint256 tknQty, uint256 ethAmt) = KMXLibrary.refundICOTokenWithEtherEnd(_icoParams, _oracleReqId, _tknPrice, _kmxToken.balanceOf(_account));
        if (tknQty > 0){
            _kmxToken.safeIcoTransfer(_account, _kmxTokenAddress, tknQty);
            KMXLibrary.notifyRefund(_icoParams, tknQty, _account);
            KMXLibrary.notifyRefundWithEther(_icoParams, _account);
            KMXLibrary.decreaseTokensSold(_icoParams, tknQty);
            emit ICOTokenRefunded(_account, tknQty);
        }
        if (ethAmt > 0) {
            address payable _payableAccount = address(uint160(_account));
            _payableAccount.transfer(ethAmt);
            emit Transfer(address(this), _account, ethAmt);
        }
    }

    function _oracleCallback(bytes32 myId, string memory result) internal {
        (uint256 stTknPrice, bool error) = result.parseToUint256();
        if (_icoParams.pendingEtherICOBuyersReqIds[myId]!=address(0)){
            buyICOTokenWithEtherEnd(myId, error?0:stTknPrice);
        }
        else if (_icoParams.pendingEtherICORefundsReqIds[myId]!=address(0)){
            refundICOTokenWithEtherEnd(myId, error?0:stTknPrice);
        }
    }

    /*function increaseTokensToSell(uint256 _value) public onlyOwner {
        KMXLibrary.increaseTokensToSell(_icoParams, _kmxTokenParts, _value);
        _kmxToken.setTotalSupply(_kmxToken.totalSupply().add(_value));
    }

    function decreaseTokensToSell(uint256 _value) public onlyOwner {
        uint256 val = KMXLibrary.decreaseTokensToSell(_icoParams, _kmxTokenParts, _value);
        _kmxToken.setTotalSupply(_kmxToken.totalSupply().sub(val));
    }*/

    /*function refundICOTokenWithEtherEnd_RefundTokens() public {
        KMXLibrary.refundICOTokenWithEtherEnd_RefundTokens(_icoParams, msg.sender);
    }*/

    /*function buyICOTokenWithEtherEnd_RefundEther() public  {
        uint256 toRfd = KMXLibrary.buyICOTokenWithEtherEnd_RefundEther(_icoParams, msg.sender);
        if (toRfd > 0){
            msg.sender.transfer(toRfd);
            emit Transfer(address(this), msg.sender, toRfd);
        }
    }*/

}