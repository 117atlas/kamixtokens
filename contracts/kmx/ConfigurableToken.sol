pragma solidity >=0.4.10 <0.6.0;

import "./ERC20ModularToken.sol";

contract ConfigurableToken is ERC20ModularToken {
    uint256 internal _transactionFees;
    mapping(string => uint256) internal _tokenPrices;
    address internal _tokenHolder;

    event TokenHolderChanged(address indexed oldTokenHolder, address indexed newTokenHolder);
    event PriceChanged(uint256 newPrice, string currency);
    event FeesChanged(uint256 newFees);

    uint256 constant internal DECIMALS = 10**18;

    constructor() public {
        _initTokenPrices(1, 1, 1);
        _transactionFees = 100;
        _tokenHolder = _owner;
    }

    function _initTokenPrices(uint256 eur, uint256 usd, uint256 xaf) internal {
        _tokenPrices["EUR"] = eur;
        _tokenPrices["USD"] = usd;
        _tokenPrices["XAF"] = xaf;
    }

    modifier notTokenHolder(address _account) {
        require(_account != _tokenHolder, "Address must not be token holder");
        _;
    }

    modifier isValidCurrency(string memory _currency) {
        require(_tokenPrices[_currency] != 0, "Currency is not present in supported currencies");
        _;
    }

    modifier isInvalidCurrency(string memory _currency) {
        require(_tokenPrices[_currency] == 0, "Currency must not be present in supported currencies");
        _;
    }

    function validCurrency(string memory _currency) public view returns(bool) {
        return _tokenPrices[_currency] != 0;
    }
    
    function tokenPrice(string memory _currency) public view isValidCurrency(_currency) returns(uint256) {
        return _tokenPrices[_currency];
    }

    function changePrice(uint256 _price, string memory _currency) public isValidCurrency(_currency) onlyAdmin {
        require(_price > 0, string(abi.encodePacked("Token price in ", _currency, " must not be 0")));
        _tokenPrices[_currency] = _price;
        emit PriceChanged(_price, _currency);
    }

    function transactionFees() public view returns(uint256) {
        return _transactionFees;
    }

    function changeFees(uint256 _fees) public onlyAdmin {
        require(_fees <= uint256(10000), "Fees must be in range 0-10000");
        _transactionFees = _fees;
        emit FeesChanged(_fees);
    }

    function changeTokenHolder(address _newHolder) public onlyOwner {
        require(_newHolder != address(0), "New Holder must not be 0-address");
        require(_newHolder != _tokenHolder, "New holder must not be old holder");
        /*address payable _payableNewHolder = address(uint160(_newHolder));
        address payable _payableTokenHolder = address(uint160(_tokenHolder));
        _payableNewHolder.transfer(_payableTokenHolder.balance);*/
        _transferAllArgs(_tokenHolder, _newHolder, balanceOf(_tokenHolder));
        emit TokenHolderChanged(_tokenHolder, _newHolder);
        _tokenHolder = _newHolder;
    }

}