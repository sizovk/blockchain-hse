// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Token} from "./MySwap3.sol";

interface Oracle {
    function pricePerToken() external view returns (uint);
    function pricePerEth() external view returns (uint);
}

contract MyLend {
    address public owner;
    uint public collRatio;
    uint liquidity;

    mapping (address => uint) balance;
    mapping (address => uint) borrow_balance;
    mapping (address => uint) deposit_balance;

    uint public LIQ_THERSHOLD;
    Token token;
    Oracle oracle;
    uint public constant BPS = 10000;

    constructor(Token _token, uint _collRatio, uint _threshold, address _oracle) {
        token = _token;
        collRatio = _collRatio;
        LIQ_THERSHOLD = _threshold;
        oracle = Oracle(_oracle);
    }

    function getBalance(address user) public view returns (uint) {
        return balance[user];
    }

    function getBorrowBalance(address user) public view returns (uint) {
        return borrow_balance[user];
    }

    function getLiquidity() public view returns(uint) {
        return liquidity;
    }

    function getEthAmount(uint _amount) internal returns (uint) {
        return _amount * oracle.pricePerEth();
    }

    function getTokenAmount(uint _amount) internal returns (uint) {
        return _amount * oracle.pricePerToken();
    }

    function deposit() public payable {
        uint amount = msg.value;
        require(amount > 0);

        liquidity += amount;
        deposit_balance[msg.sender] += amount;
    }

    function withdraw(uint amount) public {
        require(amount > 0);
        require(deposit_balance[msg.sender] >= amount);
        require(liquidity >= amount);

        deposit_balance[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success);

        
    }

    function borrow(uint amount) public payable {
        require(amount > 0);

        uint coll_amount = (BPS * getEthAmount(amount)) / collRatio;

        require(msg.value >= coll_amount, "NOT ENOUGH");

        liquidity += msg.value;

        token.transfer(msg.sender, amount);

        balance[msg.sender] += msg.value;
        borrow_balance[msg.sender] += amount;
    }

    function repay(uint amount) public {
        require(amount > 0);

        uint userBorrow = borrow_balance[msg.sender];
        uint userColl = balance[msg.sender];

        require(amount <= borrow_balance[msg.sender]);

        uint EthToPay = (userColl * amount) / userBorrow;
        require(EthToPay <= liquidity);

        token.transferFrom(msg.sender, address(this), amount);
        (bool success, ) = payable(msg.sender).call{value: EthToPay}("");

        liquidity -= EthToPay;
        borrow_balance[msg.sender] -= amount;
        balance[msg.sender] -= EthToPay;
    }

    function liquidate(address target) public payable {
        uint userBorrow = borrow_balance[target];
        uint userColl = balance[target];

        uint userBorrowPriceNow = getEthAmount(userBorrow);

        require((BPS * userBorrowPriceNow) / userColl > LIQ_THERSHOLD);

        uint coll_amount = userColl;
        borrow_balance[target] = 0;
        balance[target] = 0;
        liquidity -= coll_amount;

        require(msg.value >= coll_amount);

        liquidity += (msg.value - coll_amount);

        token.transfer(msg.sender, userBorrow);

        balance[msg.sender] += msg.value;
        borrow_balance[msg.sender] += userBorrow;
    
    }
}