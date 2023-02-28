// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BASEDAI is IBEP20 {
    string public constant name = "BASEDAI";
    string public constant symbol = "BASEDAI";
    uint8 public constant decimals = 18;
    uint256 private constant _totalSupply = 10000000 * 10 ** uint256(decimals);
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address private _owner;
    address private _marketingWallet;
    address private _developerWallet;
    
    uint256 private constant _buyFee = 10;
    uint256 private constant _sellFee = 10;
    uint256 private constant _bnbReflectionFee = 5;
    uint256 private constant _marketingFee = 2;
    uint256 private constant _developerFee = 1;

    constructor(address marketingWallet, address developerWallet) {
        _owner = msg.sender;
        _marketingWallet = marketingWallet;
        _developerWallet = developerWallet;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        _transfer(sender, recipient, amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BASEDAI: transfer from the zero address");
        require(recipient != address(0), "BASEDAI: transfer to the zero address");
        require(amount > 0, "BASEDAI: transfer amount must be greater than zero");
        
        uint256 feeAmount = 0;
        if (sender == _owner) {
            feeAmount = amount * _buyFee / 100;
        } else {
            feeAmount = amount * _sellFee / 100;
        }
        
        uint256 reflectionAmount = feeAmount * _bnbReflectionFee / 10;
        uint256 marketingAmount = feeAmount * _marketingFee / 10;
        uint256 developerAmount = feeAmount * _developerFee / 10;
    _balances[_owner] -= feeAmount;
    _balances[address(this)] += reflectionAmount;
    _balances[_marketingWallet] += marketingAmount;
    _balances[_developerWallet] += developerAmount;
    _balances[sender] -= amount;
    _balances[recipient] += amount - feeAmount;
    
    emit Transfer(sender, address(this), reflectionAmount);
    emit Transfer(sender, _marketingWallet, marketingAmount);
    emit Transfer(sender, _developerWallet, developerAmount);
    emit Transfer(sender, recipient, amount - feeAmount);
}

function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BASEDAI: approve from the zero address");
    require(spender != address(0), "BASEDAI: approve to the zero address");
    
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}

function setMarketingWallet(address marketingWallet) public {
    require(msg.sender == _owner, "BASEDAI: only the owner can set the marketing wallet");
    
    _marketingWallet = marketingWallet;
}

function setDeveloperWallet(address developerWallet) public {
    require(msg.sender == _owner, "BASEDAI: only the owner can set the developer wallet");
    
    _developerWallet = developerWallet;
}

function getMarketingWallet() public view returns (address) {
    return _marketingWallet;
}

function getDeveloperWallet() public view returns (address) {
    return _developerWallet;
}
}
