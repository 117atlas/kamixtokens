pragma solidity >=0.4.10 <0.6.0;

import "./ConfigurableToken.sol";
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