// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MyDex} from "../src/MyDex.sol";

contract Token is ERC20 {
    constructor (string memory _name, string memory _symbol, uint256 _initialSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }
}

contract MyLending {

    uint256 public collateralRatio;
    uint256 public LIQ_THRESHOLD;

    MyDex public oracle;

    uint256 liquidity;
    uint256 discount;

    address token;

    mapping (address => uint) borrow_amount;
    mapping (address => uint) balance;


    constructor(uint256 _collateralRatio, uint256 _LIQ_THRESHOLD, uint256 _discount, MyDex _oracle) { 
        collateralRatio = _collateralRatio;
        LIQ_THRESHOLD = _LIQ_THRESHOLD;
        oracle = _oracle;
        token = address(_oracle.token());
        discount = _discount;
    }

    function deposit() public payable {
        require(msg.value > 0);

        uint amount = msg.value;

        liquidity += amount;
        balance[msg.sender] += amount;
    }

    function borrow(uint amount) public payable {
        require(msg.value > 0);

        uint CollateralAmount = (1000 * oracle.SwapTokenToEther(amount)) / collateralRatio;

        require(msg.value >= CollateralAmount);

        ERC20(token).transfer(msg.sender, amount);

        liquidity += msg.value;

        balance[msg.sender] += msg.value;
        borrow_amount[msg.sender] += amount;
    }

    function repay(uint amount) public {
        require(amount > 0);
        require(borrow_amount[msg.sender] >= amount);

        ERC20(token).transferFrom(msg.sender, address(this), amount);

        uint colToWithdraw = balance[msg.sender] * (amount / borrow_amount[msg.sender]);

        liquidity -= colToWithdraw;

        (bool success, bytes memory data ) = payable(msg.sender).call{value: colToWithdraw}("");

        if (!success) {
            revert();
        }

        borrow_amount[msg.sender] -= amount;
        balance[msg.sender] -= colToWithdraw;
    }

    function withdraw(uint amount) public {
        require(amount > 0);
        require(balance[msg.sender] >= amount);
        
        (bool success, bytes memory data ) = payable(msg.sender).call{value: amount}("");

        if (!success) {
            revert();
        }

        liquidity -= amount;
        balance[msg.sender] -= amount;
    }

    function isHeath(address target) internal returns (bool) {
        uint userBorrow = borrow_amount[target];
        uint userColAmount = balance[target];

        uint userBorrowNow = oracle.SwapTokenToEther(userBorrow);

        return (10**6 * userBorrowNow / userColAmount) < LIQ_THRESHOLD;
    }

    function liquidate(address target) public {
        require(!isHeath(target));

        uint borrowAmount = borrow_amount[target];
        uint colAmount = balance[target];

        borrow_amount[target] = 0;
        balance[target] = 0;

        uint amountToPay = (100 * colAmount) / discount;

        (bool success, bytes memory data ) = payable(msg.sender).call{value: amountToPay}("");

        if (!success) {
            revert();
        }

        ERC20(token).transferFrom(msg.sender, address(this), borrowAmount);

        liquidity -= amountToPay;
        balance[msg.sender] += amountToPay;
    }

}


contract EthernautTest is Test {

    MyDex dex;
    MyLending lending;
    function setUp() public {
        dex = new MyDex(10 ** 9);
        lending = new MyLending(700, 10**6, 10, dex);      
    }

    function test_solve() public {
        
    }

    receive() external payable {
        
    }
}