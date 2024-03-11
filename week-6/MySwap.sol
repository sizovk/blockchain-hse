// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }
}

contract MySwap is ERC20 {

    Token public token;

    constructor(uint _initialSupply) payable ERC20("LP", "LPToken") {
        token = new Token("HSE", "HSEtoken", _initialSupply); 
    }

    function tokenReserve() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function ethReserve() public view returns (uint) {
        return address(this).balance;
    }

    function addLiquidity() external payable {
        uint ethReserve = ethReserve() - msg.value;

        uint tokenAmount = (msg.value * tokenReserve()) / ethReserve;

        token.transferFrom(msg.sender, address(this), tokenAmount);

        uint liquidity = (totalSupply() * msg.value) / ethReserve;
        _mint(msg.sender, liquidity);

        return liquidity;
    }

    function withdrawLiquidity(uint256 _amount) external returns (uint256, uint256) {
        require(_amount > 0, "invalid amount");
        uint256 ethAmount = (address(this).balance * _amount) / totalSupply();
        uint256 tokenAmount = (getReserve() * _amount) / totalSupply();
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
        
        return (ethAmount, tokenAmount);
    }

    function getSwapPrice(uint buyReserve, uint sellReserve, uint buyAmount) internal view {
        return (sellReserve * buyAmount) / (buyReserve + buyAmount);
    }

    function buyEther(uint tokenAmount) external {
        uint etherAmount = getSwapPrice(ethReserve(), tokenReserve(), tokenAmount);

        require(etherAmount <= ethReserve());

        // TRANSFERS

        token.transferFrom(msg.sender, address(this), tokenAmount);
        (bool success, ) = msg.sender.call{value: etherAmount}("");

        require(success);
    }

    function buyToken() external payable {
        uint buyAmount = msg.value;
        uint tokenAmount = getSwapPrice(tokenReserve(), ethReserve(), buyAmount);

        require(tokenAmount <= tokenReserve());

        token.transfer(msg.sender, tokenAmount);
    }
}