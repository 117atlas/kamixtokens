
// File: contracts\kmx\ERC20Basic.sol

pragma solidity >=0.4.10 <0.6.0;

contract ERC20Basic {
    function totalSupply() public view returns(uint256);
    function balanceOf(address account) public view returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\kmx\ERC20.sol

pragma solidity >=0.4.10 <0.6.0;

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns(uint256);
    function transferFrom(address to, address from, uint256 value) public returns(bool);
    function approve(address spender, uint256 value) public returns(bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\kmx\AdminRegistry.sol

pragma solidity >=0.4.10 <0.6.0;

contract AdminRegistry {
    struct Admin {
        mapping (address => bool) admins;
    }
}

// File: contracts\kmx\AdminLibrary.sol

pragma solidity >=0.4.10 <0.6.0;

library AdminLibrary {

    function add(AdminRegistry.Admin storage registry, address account) internal {
        require(!has(registry, account), "Account has already have admin role");
        registry.admins[account] = true;
    }

    function remove(AdminRegistry.Admin storage registry, address account) internal {
        require(has(registry, account), "Account has not have admin role");
        registry.admins[account] = false;
    }

    function has(AdminRegistry.Admin storage registry, address account) internal view returns (bool) {
        require(account != address(0), "Account must not be zero-address");
        return registry.admins[account];
    }
}

// File: contracts\kmx\Ownable.sol

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

// File: contracts\kmx\Claimable.sol

pragma solidity >=0.4.10 <0.6.0;
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

// File: contracts\kmx\Admin.sol

pragma solidity >=0.4.10 <0.6.0;

contract Admin is Claimable {
    using AdminLibrary for AdminRegistry.Admin;

    AdminRegistry.Admin private _registry;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    constructor() public {
        _addAdmin(_owner);
    }

    modifier onlyAdmin() {
        require(_registry.has(msg.sender), "Must be an admin");
        _;
    }

    function addAdmin(address admin) public onlyAdmin {
        _addAdmin(admin);
    }

    function removeAdmin(address admin) public onlyAdmin {
        _removeAdmin(admin);
    }

    function isAdmin(address account) public view returns(bool) {
        return _registry.has(account);
    }

    function renounceAdmin() public onlyAdmin {
        require(msg.sender != _owner, "Owner can not renounce to admin");
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address admin) internal {
        _registry.add(admin);
        emit AdminAdded(admin);
    }

    function _removeAdmin(address admin) internal {
        _registry.remove(admin);
        emit AdminRemoved(admin);
    }

}

// File: contracts\kmx\AccountFrozenableToken.sol

pragma solidity >=0.4.10 <0.6.0;

contract AccountFrozenableToken is Admin {
    mapping(address => bool) frozenAccounts;

    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);

    function _isAccountFrozen(address _account) internal view returns(bool) {
        return frozenAccounts[_account];
    }

    modifier accountFrozen(address _account) {
        require(_isAccountFrozen(_account), "Account must be frozen");
        _;
    }

    modifier accountNotFrozen(address _account) {
        require(!_isAccountFrozen(_account), "Account must not be frozen");
        _;
    }

    function isAccountFrozen(address _account) public view returns(bool) {
        return _isAccountFrozen(_account);
    }

    function frozeAccount(address _account) public onlyAdmin accountNotFrozen(_account) {
        frozenAccounts[_account] = true;
        emit AccountFrozen(_account);
    }

    function unfrozeAccount(address _account) public onlyAdmin accountFrozen(_account) {
        frozenAccounts[_account] = false;
        emit AccountUnfrozen(_account);
    }
}

// File: contracts\kmx\utils\SafeMath.sol

pragma solidity >=0.4.10 <0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts\kmx\ERC20ModularToken.sol

pragma solidity >=0.4.10 <0.6.0;

contract ERC20ModularToken is ERC20, AccountFrozenableToken {
    uint256 internal _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    using SafeMath for uint256;

    function _getBalance(address account) internal view returns(uint256) {
        return balances[account];
    }

    function _addBalance(address account, uint256 value) internal {
        balances[account] = balances[account].add(value);
    }

    function _subBalance(address account, uint256 value) internal {
        balances[account] = balances[account].sub(value);
    }

    function _setBalance(address account, uint256 value) internal {
        balances[account] = value;
    }

    function _getAllowance(address owner, address spender) internal view returns(uint256) {
        return allowances[owner][spender];
    }

    function _addAllowance(address owner, address spender, uint256 value) internal {
        allowances[owner][spender] = allowances[owner][spender].add(value);
    }

    function _subAllowance(address owner, address spender, uint256 value) internal {
        allowances[owner][spender] = allowances[owner][spender].sub(value);
    }

    function _setAllowance(address owner, address spender, uint256 value) internal {
        allowances[owner][spender] = value;
    }

    function _approveAllArgs(address owner, address spender, uint256 value) internal {
        _setAllowance(owner, spender, value);
        emit Approval(msg.sender, spender, value);
    }

    function _increaseAllowanceAllArgs(address owner, address spender, uint256 value) internal {
        _addAllowance(owner, spender, value);
        emit Approval(msg.sender, spender, _getAllowance(owner, spender));
    }

    function _decreaseAllowanceAllArgs(address owner, address spender, uint256 value) internal {
        _subAllowance(owner, spender, value);
        emit Approval(msg.sender, spender, _getAllowance(owner, spender));
    }

    function _transferAllArgs(address from, address to, uint256 value) internal {
        if (address(to)!=address(this)) _addBalance(to, value);
        if (address(from)!=address(this)) _subBalance(from, value);
        emit Transfer(from, to, value);
    }

    function _transferFromAllArgs(address from, address to, uint256 value, address spender) internal {
        if (address(to)!=address(this)) _addBalance(to, value);
        _subAllowance(from, spender, value);
        if (address(from)!=address(this)) _subBalance(from, value);
        emit Transfer(from, to, value);
    }

    function increaseAllowance(address spender, uint256 value) public {
        require(msg.sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _increaseAllowanceAllArgs(msg.sender, spender, value);
    }

    function decreaseAllowance(address spender, uint256 value) public {
        require(msg.sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _decreaseAllowanceAllArgs(msg.sender, spender, value);
    }

    function approve(address spender, uint256 value) public returns(bool) {
        require(msg.sender != address(0), "Sender must not be 0-address");
        require(spender != address(0), "Spender must not be 0-address");
        _approveAllArgs(msg.sender, spender, value);
        return true;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _getBalance(account);
    }

    function allowance(address owner, address spender) public view returns(uint256) {
        return _getAllowance(owner, spender);
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function transferFrom(address to, address from, uint256 value) public returns(bool){
        _transferFromAllArgs(from, to, value, msg.sender);
    }

    function transfer(address to, uint256 value) public returns(bool){
        _transferAllArgs(msg.sender, to, value);
    }

}

// File: contracts\kmx\ConfigurableToken.sol

pragma solidity >=0.4.10 <0.6.0;

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

// File: contracts\kmx\MintBurnToken.sol

pragma solidity >=0.4.10 <0.6.0;
//import "./utils/SafeMath.sol";

contract MintBurnToken is ConfigurableToken {
    bool private _allowMintBurn;

    event MintBurnAllowanceChanged(bool _newState);
    event Minted(uint256 value, uint256 newTotalSupply);
    event Burned(uint256 value, uint256 newTotalSupply);

    //using SafeMath for uint256;

    constructor() public {
        _allowMintBurn = false;
    }

    modifier mintBurnAllowed() {
        require(_allowMintBurn, "Mint and burn operations not allowed");
        _;
    }

    function isMintBurnAllowed() public view returns(bool) {
        return _allowMintBurn;
    }

    function mint(uint256 _value) public onlyAdmin mintBurnAllowed {
        _addBalance(_tokenHolder, _value);
        _totalSupply = _totalSupply.add(_value);
        emit Minted(_value, totalSupply());
        emit Transfer(address(0), _tokenHolder, _value);
    }

    function burn(uint256 _value) public onlyAdmin mintBurnAllowed returns(uint256) {
        uint256 _vtb = _value;
        if (balanceOf(_tokenHolder) < _value){
            _vtb = balanceOf(_tokenHolder);
        }
        _subBalance(_tokenHolder, _vtb);
        _totalSupply = _totalSupply.sub(_vtb);
        emit Burned(_value, totalSupply());
        emit Transfer(_tokenHolder, address(0), _vtb);
        return _vtb;
    }

    function changeMintBurnAllowance(bool _newState) public onlyOwner {
        require(_allowMintBurn == !_newState, string(abi.encodePacked("New Mint Allowance must be ", !_newState)));
        _allowMintBurn = _newState;
        emit MintBurnAllowanceChanged(_newState);
    }

}

// File: contracts\kmx\utils\AddressUtils.sol

pragma solidity >=0.4.10 <0.6.0;

library AddressUtils {
    function isContractAddress(address _address) internal view returns(bool) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
}

// File: contracts\kmx\KMXToken.sol

pragma solidity >=0.4.10 <0.6.0;

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

// File: contracts\kmx\KMXStableToken.sol

pragma solidity >=0.4.10 <0.6.0;

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
            require(balanceOf(msg.sender) > value.add(fees), "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
            _transferAllArgs(msg.sender, _tokenHolder, fees);
        }
        else {
            require(balanceOf(msg.sender) > value, "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
        }
        return true;
    }

    function kmxStableTokenTransferFrom(address from, address to, uint256 value) public 
    accountNotFrozen(msg.sender) accountNotFrozen(from) accountNotFrozen(to) notTokenHolder(msg.sender) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        require(msg.sender != address(0), "Spender address must not be 0-address");
        require(value > 0, "Amount must be greater than 0");
        if (_transactionFees > 0) {
            uint256 fees = value.mul(_transactionFees).div(10000);
            require(balanceOf(from) > value.add(fees), "Sender unsufficient funds");
            require(allowance(from, msg.sender) > value.add(fees), "Spender unsufficient fees");
            _transferFromAllArgs(from, to, value, msg.sender);
            _transferFromAllArgs(from, _tokenHolder, fees, msg.sender);
        }
        else{
            require(balanceOf(from) > value, "Sender unsufficient funds");
            require(allowance(from, msg.sender) > value, "Spender unsufficient fees");
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
            require(balanceOf(msg.sender) > value, "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
            return _kmxToken.SafeFeesForStableTokenTransfer(msg.sender, fees);
        }
        else {
            require(balanceOf(msg.sender) > value, "Sender Unsifficient funds");
            _transferAllArgs(msg.sender, to, value);
        }
        return true;
    }

    function kmxStableTokenTransferFromKMXFees(address from, address to, uint256 value, uint256 stableTokenPrice) public
    accountNotFrozen(msg.sender) accountNotFrozen(from) accountNotFrozen(to) notTokenHolder(msg.sender) returns(bool) {
        require(to != address(0), "Receiver address must not be 0-address");
        require(from != address(0), "Sender address must not be 0-address");
        require(msg.sender != address(0), "Spender address must not be 0-address");
        require(value > 0, "Amount must be greater than 0");
        if (_transactionFees > 0) {
            uint256 fees = value.mul(_transactionFees).div(10000);
            fees = fees.mul(DECIMALS).div(stableTokenPrice);
            fees = fees.mul(uint256(100).sub(_kmxTokenDiscountForFees)).div(100);
            require(balanceOf(from) > value, "Sender unsufficient funds");
            require(allowance(from, msg.sender) > value, "Spender unsufficient fees");
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

// File: contracts\kmx\KMXStable.sol

pragma solidity >=0.4.10 <0.6.0;

contract KMXStable is KMXStableToken {
    string public name = "Kamix Stable";
    string public symbols = "KEUR";
    uint256 public decimals = 18;

    function setName(string calldata _name) external onlyOwner {
        require(bytes(_name).length != 0, "Name must not be empty");
        name = _name;
    }

    function setSymbols(string calldata _symbols) external onlyOwner {
        require(bytes(_symbols).length != 0, "Symbols must not be empty");
        symbols = _symbols;
    }
    
}
