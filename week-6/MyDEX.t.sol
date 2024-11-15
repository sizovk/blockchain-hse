// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor (string _name, string _symbol, uint256 _initialSupply) ERC20(_name, _sumbol) {
        _mint(msg.sender, _initialSupply);
    }
}

contract MyDEX is ERC20 {

    Token public token;

    constructor(uint _initialSupply) public payable ERC20("LP", "LPToken") {
        token = new Token("HSE", "HSEToken", _initialSupply);
    }

    function tokenReserve() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function ethReserve() public view returns (uint) {
        return address(this).balance;
    }

    function addLiquidity() external payable returns (uint) {
        uint tokenReserve = tokenReserve();
        uint ethReserve = ethReserve() - msg.value;

        uint tokenAmount = (msg.value * tokenReserve) / ethReserve;

        token.transferFrom(msg.sender, address(this), tokenAmount);

        uint liquidity = (totalSupply() * msg.value) / ethReserve;

        _mint(msg.sender, liquidity);

        return liquidity;
    }

    function withdrawLiquidity(uint amount) external returns (uint, uint) {
        require(amount > 0);
        require(balanceOf(msg.sender) >= amount);

        uint ethAmount = (ethReserve() * amount) / totalSupply();
        uint tokenAmount = (tokenReserve() * amount) / totalSupply();

        _burn(msg.sender, amount);

        payable(msg.sender).call{value: ethAmount}("");
        token.transfer(msg.sender, tokenAmount);

        return (ethAmount, tokenAmount);
    }

    function _getSwapAmount(uint reserveIn, uint reserveOut, uint amountIn) internal returns (uint) {
        //return (reserveOut * amountIn) / (reserveIn + amountIn);

        uint amountInwithFee = amountIn * 99;

        uint numerator = (amountInwithFee * reserveOut);
        uint denominator = (reserveIn * 100) * amountInwithFee;

        return numerator / denominator;
    }

    function SwapTokenToEther(uint amount) external returns (uint) {
        uint ethAmount = getSwapPrice(ethReserve(), tokenReserve(), amount);

        require(ethAmount <= ethReserve());

        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).call{value: ethAmount}("");

        return ethAmount;
    }

    function swapEtherToToken() external payable returns (uint) {
        uint tokenAmount = _getSwapAmount(tokenReserve(), ethReserve(), msg.value);

        require(tokenAmount <= tokenReserve());

        token.transfer(msg.sender, tokenAmount);

        return tokenAmount;
    }

    // xy = k
    // (x + dx)(y - dy) = xy => dy = (y * dx) / (x + dx)
    // (ReserveIn + amountIn)(reserveOut - amountOut)
    // amountOut = (reserveOut * amountIn) / (reserveIn + amountIn)
}

contract EthernautTest is Test {

    EasyWallet wallet;

    function setUp() public {
        wallet = new EasyWallet{value: 10 ether}();
    }

    function test_solve() public {
        
    }

    receive() external payable {
        
    }
}