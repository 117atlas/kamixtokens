pragma solidity >=0.4.10 <0.6.0;

import "./utils/SafeMath.sol";
import "./utils/Oracle.sol";

library KMXStableMarketLib {
    event FeedbackBuyKMX(address indexed buyer, string feedback);
    event TokenSellerAdded(address indexed seller);
    event TokenSellerRemoved(address indexed seller);

    struct KMXMarketData {
        mapping(address => bool) tokenSellers;
        mapping(address => bool) requestBuyKMXTokens;
        mapping(bytes32 => address) buyKMXBuyersReqIds;
        mapping(address => uint256) buyKMXBuyers;
    }

    uint256 internal constant DECIMALS = 10**18;

    using SafeMath for uint256;

    function isSeller(KMXMarketData storage data, address _seller) internal view returns(bool) {
        return data.tokenSellers[_seller];
    }

    function addSeller(KMXMarketData storage data, address _seller) internal {
        data.tokenSellers[_seller] = true;
        emit TokenSellerAdded(_seller);
    }

    function removeSeller(KMXMarketData storage data, address _seller) internal {
        data.tokenSellers[_seller] = false;
        emit TokenSellerRemoved(_seller);
    }

    function buy(uint256 _tknPrice, uint256 _amount, uint256 _fromBalance) internal pure returns(uint256, uint256) {
        uint256 tknPrice = _tknPrice;
        uint256 amt = _amount;
        uint256 tknQty = amt.mul(tknPrice).div(DECIMALS);
        uint256 rfd = 0;
        if (tknQty > _fromBalance){
            uint256 nwTknQty = _fromBalance;
            uint256 nwAmt = nwTknQty.mul(DECIMALS).div(tknPrice);
            rfd = amt.sub(nwAmt);
            amt = nwAmt;
            tknQty = nwTknQty;
        }
        return(tknQty, rfd);
    }

    function refundAmount(uint256 _tknPrice, uint256 _tokenQuantity) internal pure returns(uint256) {
        return _tokenQuantity.mul(DECIMALS).div(_tknPrice);
    }

    function buyKMXTokens(KMXMarketData storage data, uint256 _amount, address _account, uint256 _accountBalance, Oracle oracle, string memory _stableTokenPriceUrl) internal {
        require(_accountBalance >= _amount, "Unsufficient balances");
        bytes32 reqId = oracle.query("URL", string(abi.encodePacked("json(", _stableTokenPriceUrl, ").price")));
        data.buyKMXBuyersReqIds[reqId] = _account;
        data.buyKMXBuyers[_account] = _amount;
        data.requestBuyKMXTokens[_account] = true;
    }

    function exchangeKMXTokens(KMXMarketData storage data, bytes32 _oracleReqId, uint256 stableTokenPrice, uint256 _buyKMXFees, uint256 _accountBalance) internal returns(uint256, uint256) { // 1 KMX ===? x KEUR
        address _account = data.buyKMXBuyersReqIds[_oracleReqId];
        uint256 amount = data.buyKMXBuyers[_account];
        uint256 kmxTokensQuantity = 0;
        uint256 fees = 0;
        if (!data.requestBuyKMXTokens[_account]){
            emit FeedbackBuyKMX(_account, "Sender has not requested buy KMX Tokens");
        }
        else if (_accountBalance < amount){
            emit FeedbackBuyKMX(_account, "Unsufficient balances");
        }
        else{
            fees = amount.mul(_buyKMXFees).div(10000);
            uint256 amountToUse = amount.sub(fees);
            kmxTokensQuantity = amountToUse.mul(DECIMALS).div(stableTokenPrice);
        }
        delete data.buyKMXBuyers[_account];
        delete data.requestBuyKMXTokens[_account];
        delete data.buyKMXBuyersReqIds[_oracleReqId];
        return(kmxTokensQuantity, fees);
    }

}