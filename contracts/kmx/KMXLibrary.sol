pragma solidity >=0.4.10 <0.6.0;

import "./utils/SafeMath.sol";
import "./utils/Oracle.sol";

library KMXLibrary {
    enum ICOState {
        ICO_PENDING,
        ICO_ONGOING,
        ICO_PAUSED,
        ICO_ENDED
    }

    struct KMXTokenParts {
        uint256 _tokensToSell;
        uint256 _reserveTokens;
        uint256 _circulatingTokens;
    }

    struct ICOParams {
        ICOState _icoState;
        uint256 _icoStartDate;
        uint256 _icoEndDate;
        uint256 _tokensToSell_remaining;
        uint256 _tokensToSell_sold;

        mapping(address => uint256) pendingEtherICOBuyers;
        mapping(address => uint256) pendingEtherICORefunds;
        mapping(bytes32 => address) pendingEtherICOBuyersReqIds;
        mapping(bytes32 => address) pendingEtherICORefundsReqIds;
        mapping(address => uint256) _icoBuyers;
        mapping(address => bool) _etherIcoBuyers;
        bool _buyWithEther;
    }

    uint256 internal constant DECIMALS = 10**18;

    using SafeMath for uint256;

    function init(ICOParams storage params, KMXTokenParts storage _kmxTokenParts) internal {
        params._icoState = ICOState.ICO_PENDING;
        params._icoStartDate = 0;
        params._icoEndDate = 0;
        params._buyWithEther = false;
        params._tokensToSell_sold = 0;
        params._tokensToSell_remaining = _kmxTokenParts._tokensToSell;
    }

    function enableBuyWithEther(ICOParams storage params) internal {
        params._buyWithEther = true;
    }

    function disableBuyWithEther(ICOParams storage params) internal {
        params._buyWithEther = false;
    }

    function startICO(ICOParams storage params) internal {
        require(params._icoState == ICOState.ICO_PENDING, "ICO Must be in pending state");
        params._icoState = ICOState.ICO_ONGOING;
        params._icoStartDate = block.number;
    }

    function pauseICO(ICOParams storage params) internal {
        require(params._icoState == ICOState.ICO_ONGOING, "ICO Must be in ongoing state");
        params._icoState = ICOState.ICO_PAUSED;
    }

    function continueICO(ICOParams storage params) internal {
        require(params._icoState == ICOState.ICO_PAUSED, "ICO Must be in paused state");
        params._icoState = ICOState.ICO_ONGOING;
    }

    function endICO(ICOParams storage params, KMXTokenParts storage _kmxTokenParts) internal {
        require(params._icoState == ICOState.ICO_PAUSED || params._icoState == ICOState.ICO_ONGOING, "ICO Must be in ongoing or paused state");
        params._icoState = ICOState.ICO_ENDED;
        params._icoEndDate = block.number;
        _kmxTokenParts._circulatingTokens = _kmxTokenParts._circulatingTokens.add(params._tokensToSell_sold);
    }

    function statusICO(ICOParams storage params) internal view returns(string memory) {
        if (params._icoState == ICOState.ICO_ONGOING) return "ON GOING";
        else if (params._icoState == ICOState.ICO_PAUSED) return "PAUSED";
        else if (params._icoState == ICOState.ICO_ENDED) return "ENDED";
        else return "PENDING";
    }

    function tokensPart(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint8 part) internal view returns(uint256) {
        if (part == 10) return _kmxTokenParts._tokensToSell;
        if (part == 11) return params._tokensToSell_remaining;
        if (part == 12) return params._tokensToSell_sold;
        else if (part == 20) return _kmxTokenParts._reserveTokens;
        else return _kmxTokenParts._circulatingTokens;
    }

    function increaseTokensToSell(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint256 _value) internal {
        require(params._icoState == ICOState.ICO_PENDING || params._icoState == ICOState.ICO_PAUSED, "ICO must be in pending or paused state");
        _kmxTokenParts._tokensToSell = _kmxTokenParts._tokensToSell.add(_value);
        params._tokensToSell_remaining = params._tokensToSell_remaining.add(_value);
    }

    function decreaseTokensToSell(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint256 _value) internal returns(uint256) {
        require(params._icoState == ICOState.ICO_PENDING || params._icoState == ICOState.ICO_PAUSED, "ICO must be in pending or paused state");
        uint256 val = _value;
        if (params._tokensToSell_remaining < _value){
            val = params._tokensToSell_remaining;
        }
        _kmxTokenParts._tokensToSell = _kmxTokenParts._tokensToSell.sub(val);
        params._tokensToSell_remaining = params._tokensToSell_remaining.sub(val);
        return val;
    }

    function increaseTokensSold(ICOParams storage params, uint256 _tokensQuantity) internal {
        params._tokensToSell_sold = params._tokensToSell_sold.add(_tokensQuantity);
        params._tokensToSell_remaining = params._tokensToSell_remaining.sub(_tokensQuantity);
    }

    function decreaseTokensSold(ICOParams storage params, uint256 _tokensQuantity) internal {
        params._tokensToSell_sold = params._tokensToSell_sold.sub(_tokensQuantity);
        params._tokensToSell_remaining = params._tokensToSell_remaining.add(_tokensQuantity);
    }

    function notifyTokensBought(ICOParams storage params, uint256 _tokensQuantity, address _account) internal {
        params._icoBuyers[_account] = params._icoBuyers[_account].add(_tokensQuantity);
    }

    function notifyRefund(ICOParams storage params, uint256 _tokensQuantity, address _account) internal {
        params._icoBuyers[_account] = params._icoBuyers[_account].sub(_tokensQuantity);
    }

    function notifyTokensBoughtWithEther(ICOParams storage params, address _account) internal {
        params._etherIcoBuyers[_account] = true;
    }

    function notifyRefundWithEther(ICOParams storage params, address _account) internal {
        params._etherIcoBuyers[_account] = false;
    }

    function reserveToSell(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint256 _amount) internal {
        require(params._icoState == ICOState.ICO_PENDING || params._icoState == ICOState.ICO_PAUSED, "ICO must be in pending or paused state");
        require(_amount <= _kmxTokenParts._reserveTokens, "Amount to withdraw from reserve exceeds reserve funds");
        _kmxTokenParts._tokensToSell = _kmxTokenParts._tokensToSell.add(_amount);
        params._tokensToSell_remaining = params._tokensToSell_remaining.add(_amount);
        _kmxTokenParts._reserveTokens = _kmxTokenParts._reserveTokens.sub(_amount);
    }

    function sellToReserve(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint256 _amount) internal {
        require(params._icoState != ICOState.ICO_ONGOING, "ICO must not be in ongoing state");
        require(_amount <= params._tokensToSell_remaining, "Amount to withdraw from sell tokens exceeds remaining tokens to sell");
        params._tokensToSell_remaining = params._tokensToSell_remaining.sub(_amount);
        _kmxTokenParts._tokensToSell = _kmxTokenParts._tokensToSell.sub(_amount);
        _kmxTokenParts._reserveTokens = _kmxTokenParts._reserveTokens.add(_amount);
    }

    function sellToCirculation(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint256 _amount) internal {
        require(params._icoState != ICOState.ICO_ONGOING, "ICO must not be in ongoing state");
        require(_amount <= params._tokensToSell_remaining, "Amount to withdraw from sell tokens exceeds remaining tokens to sell");
        _kmxTokenParts._tokensToSell = _kmxTokenParts._tokensToSell.sub(_amount);
        params._tokensToSell_remaining = params._tokensToSell_remaining.sub(_amount);
        _kmxTokenParts._circulatingTokens = _kmxTokenParts._circulatingTokens.add(_amount);
    }

    function circulationToSell(ICOParams storage params, KMXTokenParts storage _kmxTokenParts, uint256 _amount, uint256 _tokenHolderBalance) internal {
        require(params._icoState == ICOState.ICO_PENDING || params._icoState == ICOState.ICO_PAUSED, "ICO must be in pending or paused state");
        require(_amount <= _tokenHolderBalance, "Amount to withdraw from projects tokens exceeds remaining tokens to sell");
        _kmxTokenParts._tokensToSell = _kmxTokenParts._tokensToSell.add(_amount);
        params._tokensToSell_remaining = params._tokensToSell_remaining.add(_amount);
        _kmxTokenParts._circulatingTokens = _kmxTokenParts._circulatingTokens.sub(_amount);
    }

    function reserveToCirculation(KMXTokenParts storage _kmxTokenParts, uint256 _amount) internal {
        require(_amount < _kmxTokenParts._reserveTokens, "Amount to withdraw from reserve exceeds reserve funds");
        _kmxTokenParts._reserveTokens = _kmxTokenParts._reserveTokens.sub(_amount);
        _kmxTokenParts._circulatingTokens = _kmxTokenParts._circulatingTokens.add(_amount);
    }

    function circulationToReserve(KMXTokenParts storage _kmxTokenParts, uint256 _amount, uint256 _tokenHolderBalance) internal {
        require(_amount < _tokenHolderBalance, "Amount to withdraw from reserve exceeds project funds");
        _kmxTokenParts._reserveTokens = _kmxTokenParts._reserveTokens.add(_amount);
        _kmxTokenParts._circulatingTokens = _kmxTokenParts._circulatingTokens.sub(_amount);
    }

    function buyICOTokensForAccount(ICOParams storage params, uint256 _tknPrice, uint256 _amount) internal view returns(uint256, uint256) {
        require(_amount > 0, "Amount offered must be greater than 0");
        require(params._tokensToSell_remaining > 0, "There are no more tokens to sell");
        uint256 tknPrice = _tknPrice;
        uint256 amt = _amount;
        uint256 tknQty = amt.mul(tknPrice).div(DECIMALS);
        uint256 rfd = 0;
        if (params._tokensToSell_remaining < tknQty){
            uint256 nwTknQty = params._tokensToSell_remaining;
            uint256 nwAmt = nwTknQty.mul(DECIMALS).div(tknPrice);
            rfd = amt.sub(nwAmt);
            amt = nwAmt;
            tknQty = nwTknQty;
        }
        return(tknQty, rfd);
    }

    function refundICOAmount(uint256 _tknPrice, uint256 _tokenQuantity) internal pure returns(uint256) {
        require(_tokenQuantity > 0, "Tokens quantity must be greater than 0");
        // 1 Curr ==> tokenPrice Tokens
        return _tokenQuantity.mul(DECIMALS).div(_tknPrice);
    }

    function refundICO(ICOParams storage params, address _account, uint256 _tokenQuantity) internal view returns(bool) {
        require(_tokenQuantity > 0, "Tokens quantity must be greater than 0");
        require(_tokenQuantity <= params._icoBuyers[_account], "Tokens quantity must be less than quantity user bought");
        return true;
    }

    function buyICOTokensWithEther(ICOParams storage params, address _account, uint256 _ethAmt, Oracle oracle, uint256 _buyRefundWithEtherFees, string storage _tknEtherPriceOracleUrl) internal returns(bool)  {
        require(_account != address(0), "Account address must not be null");
        require(_ethAmt > _buyRefundWithEtherFees, string(abi.encodePacked("Value offered must be greater than fees (", _buyRefundWithEtherFees, ")")));
        require(params._tokensToSell_remaining > 0, "There must have tokens to buy");
        if (params.pendingEtherICOBuyers[_account] > 0){
            return false;
        }
        bytes32 reqId = oracle.query("URL", string(abi.encodePacked("json(", _tknEtherPriceOracleUrl, ").price")));
        params.pendingEtherICOBuyersReqIds[reqId] = _account;
        params.pendingEtherICOBuyers[_account] = _ethAmt;
        return true;
    }

    function buyICOTokenWithEtherEnd(ICOParams storage params, uint256 _buyRefundWithEtherFees, bytes32 _oracleReqId, uint256 _tknPrice) internal returns(bool, uint256, uint256, address, uint256) {
        require(params.pendingEtherICOBuyersReqIds[_oracleReqId] != address(0), "Invalid oracle req id");
        address _account = params.pendingEtherICOBuyersReqIds[_oracleReqId];
        if (params.pendingEtherICOBuyers[_account] <= _buyRefundWithEtherFees){ //equivalent a == 0
            emit FeedbackBuyICOWithEther(_account, "Buyer must have been initialize buy transaction");
            return (true, 0, 0, _account, params.pendingEtherICOBuyers[_account]);
        }
        uint256 tknQty = 0;
        uint256 rfd = 0;
        bool fb = true;
        uint256 ethAmt = params.pendingEtherICOBuyers[_account];
        if (_tknPrice==0) fb = false;
        else{
            ethAmt = ethAmt.sub(_buyRefundWithEtherFees);
            tknQty = ethAmt.mul(_tknPrice).div(DECIMALS);
            rfd = 0;
            if (params._tokensToSell_remaining < tknQty) {
                uint256 nwTknQty = params._tokensToSell_remaining;
                uint256 nwAmt = nwTknQty.mul(DECIMALS).div(_tknPrice);
                rfd = ethAmt.sub(nwAmt);
                ethAmt = nwAmt;
                tknQty = nwTknQty;
            }
        }
        params.pendingEtherICOBuyers[_account] = 0;
        delete params.pendingEtherICOBuyersReqIds[_oracleReqId];
        return(fb, tknQty, rfd, _account, ethAmt);
    }

    function buyICOTokenWithEtherEnd_RefundEther(ICOParams storage params, address _account) internal returns(uint256) {
        require(_account!=address(0), "Account address must not be 0-address");
        require(params.pendingEtherICOBuyers[_account] > 0, "Buyer must have been initialize buy transaction");
        uint256 _toRfd = params.pendingEtherICOBuyers[_account];
        params.pendingEtherICOBuyers[_account] = 0;
        return _toRfd;
    }

    function refundICOTokenWithEther(ICOParams storage params, address _account, uint256 _tokenQuantity, Oracle oracle, string storage _tknEtherPriceOracleUrl) internal returns(bool) {
        require(_tokenQuantity > 0, "Tokens quantity must be greater than 0");
        require(_account != address(0), "Account address must not be null");
        require(params._icoBuyers[_account] >= _tokenQuantity, "Account have not bought this quantity of tokens");
        require(params._etherIcoBuyers[_account], "Account must have bought tokens with ethers");
        bytes32 reqId = oracle.query("URL", string(abi.encodePacked("json(", _tknEtherPriceOracleUrl, ").price")));
        params.pendingEtherICORefundsReqIds[reqId] = _account;
        params.pendingEtherICORefunds[_account] = _tokenQuantity;
        return true;
    }

    function refundICOTokenWithEtherEnd(ICOParams storage params, bytes32 _oracleReqId, uint256 _tknPrice, uint256 _balanceOfAccount) internal returns(uint256, uint256) {
        address _account = params.pendingEtherICOBuyersReqIds[_oracleReqId];
        if (params.pendingEtherICORefunds[_account]==0) {
            emit FeedbackRefundICOWithEther(_account, "User must have been initialize the ICO refund tokens transaction");
            return (0, 0);
        }
        uint256 tknQty = 0;
        uint256 ethAmt = 0;
        if (_tknPrice != 0){
            tknQty = params.pendingEtherICORefunds[_account];
            ethAmt = tknQty.mul(DECIMALS).div(_tknPrice);
            if (!params._etherIcoBuyers[_account]){
                emit FeedbackRefundICOWithEther(_account, "Buyer does not bought tokens with ether");
            }
            else if (_balanceOfAccount < tknQty){
                emit FeedbackRefundICOWithEther(_account, "Unsufficient funds");
            }
        }
        params.pendingEtherICORefunds[_account] = 0;
        delete params.pendingEtherICORefundsReqIds[_oracleReqId];
        return(tknQty, ethAmt);
    }

    function refundICOTokenWithEtherEnd_RefundTokens(ICOParams storage params, address _account) public returns(bool) {
        require(_account!=address(0), "Account address must not be 0-address");
        require(params.pendingEtherICORefunds[_account] > 0, "User must have been initialize the ICO refund tokens transaction");
        params.pendingEtherICORefunds[_account] = 0;
        return true;
    }

    event FeedbackBuyICOWithEther(address indexed buyer, string feedback);
    event FeedbackRefundICOWithEther(address indexed refunder, string feedback);
}