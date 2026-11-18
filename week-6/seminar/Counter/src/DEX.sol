// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract MyDEX is ERC20 {
    address public immutable token0;
    address public immutable token1;

    uint256 private reserve0;
    uint256 private reserve1;

    bool private flag;

    modifier nonReentrant() {
        require(!flag, "REENTRANCY!");
        flag = true;
        _;
        flag = false;
    }
    
    uint256 private immutable FEE_NUMERATOR = 997;
    uint256 private immutable FEE_DENOMINATOR = 1000;

    event LiquidityAdded(address sender, address receiver, uint256 liquidity, uint256 amount0, uint256 amount1);
    event LiquidityRemoved(address sender, address receiver, uint256 liquidity, uint256 amount0, uint256 amount1);
    event Sync(uint256 r0, uint256 r1);
    event Swap(address token0, address token1, address sender, address receiver, uint256 amount0In, uint256 amount1Out);

    constructor(address _token0, address _token1) ERC20("MyDEXLP Token", "LP") {
        require(_token0 != address(0) && _token1 != address(0), "ZERO_ADDRESS");
        require(_token0 != _token1, "SAME_TOKENS");
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view returns (uint256 r0, uint256 r1) {
        r0 = reserve0;
        r1 = reserve1;
    }

    function _updateReserves(uint256 balance0, uint256 balance1) internal {
        reserve0 = balance0;
        reserve1 = balance1;
        emit Sync(reserve0, reserve1);
    }

    function addLiquidity(uint256 amount0Desired, uint256 amount1Desired, address receiver)
        external nonReentrant
        returns (uint256 liquidity, uint256 amount0, uint256 amount1)
    {
        require(receiver != address(0), "ZERO RECEIVER");
        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        if (_reserve0 == 0 && _reserve1 == 0) {
            amount0 = amount0Desired;
            amount1 = amount1Desired;
        } else {
            uint256 amount0Optimal = (amount0Desired * _reserve1) / reserve0;
            if (amount0Optimal <= amount0Desired) {
                amount0 = amount0Optimal;
                amount1 = amount1Desired;
            } else {
                uint256 amount1Optimal = (amount1Desired * _reserve0) / reserve1;
                if (amount1Optimal <= amount1Desired) {
                    amount0 = amount0Desired;
                    amount1 = amount1Optimal;
                } else {
                    revert("INCORRECT AMOUNTS");
                }
            }
        }

        ERC20(token0).transferFrom(msg.sender, address(this), amount0);
        ERC20(token1).transferFrom(msg.sender, address(this), amount1);

        uint256 totalSupply = totalSupply();

        if (totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1);
        } else {
            liquidity = Math.min((totalSupply * amount0) / _reserve0, (totalSupply * amount1) / _reserve1);
        }

        _mint(receiver, liquidity);

        uint256 newReserve0 = _reserve0 + amount0;
        uint256 newReserve1 = _reserve1 + amount1;
        _updateReserves(newReserve0, newReserve1);

        emit LiquidityAdded(msg.sender ,receiver, liquidity, amount0, amount1);
    }

    function removeLiquidty(uint256 liquidity, address receiver)
        external nonReentrant
        returns (uint256 amount0, uint256 amount1) 
    {
        require(receiver != address(0), "ZERO RECEIVER");

        (uint256 _reserve0, uint256 _reserve1) = getReserves();

        uint256 totalSupply = totalSupply();

        require(balanceOf(msg.sender) >= liquidity, "INSUFFICIENT LIQUIDITY");

        _burn(msg.sender, liquidity);

        amount0 = (_reserve0 * liquidity) / totalSupply;
        amount1 = (_reserve1 * liquidity) / totalSupply;

        ERC20(token0).transfer(receiver, amount0);
        ERC20(token1).transfer(receiver, amount1);

        uint256 newReserve0 = _reserve0 - amount0;
        uint256 newReserve1 = _reserve1 - amount1;
        _updateReserves(newReserve0, newReserve1);

        emit LiquidityRemoved(msg.sender, receiver, liquidity, amount0, amount1);
    }

    function SwapZeroToOne(uint256 amount0In, uint256 minAmount1Out, address receiver)
        external
        nonReentrant
        returns (uint256 amount1Out)
    {
        require(receiver != address(0), "ZERO RECEIVER");
        require(amount0In != 0, "ZERO AMOUNT IN");

        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        
        ERC20(token0).transferFrom(msg.sender, address(this), amount0In);

        uint256 amount0WithFee = (amount0In * FEE_NUMERATOR) / FEE_DENOMINATOR;

        uint256 numerator = amount0WithFee * _reserve1;
        uint256 denominator = _reserve0 + amount0WithFee;

        amount1Out = numerator / denominator;

        require(amount1Out >= minAmount1Out, "SLIPPAGE!");

        ERC20(token1).transfer(receiver, amount1Out);

        uint256 newReserve0 = _reserve0 + amount0In;
        uint256 newReserve1 = _reserve1 - amount1Out;
        _updateReserves(newReserve0, newReserve1);

        emit Swap(token0, token1, msg.sender, receiver, amount0In, amount1Out);
    }

    function SwapOneToZero(uint256 amount1In, uint256 minAmount0Out, address receiver)
        external
        nonReentrant
        returns (uint256 amount0Out)
    {
        require(receiver != address(0), "ZERO RECEIVER");
        require(amount1In != 0, "ZERO AMOUNT IN");

        (uint256 _reserve0, uint256 _reserve1) = getReserves();
        
        ERC20(token1).transferFrom(msg.sender, address(this), amount1In);

        uint256 amount1WithFee = (amount1In * FEE_NUMERATOR) / FEE_DENOMINATOR;

        uint256 numerator = amount1WithFee * _reserve0;
        uint256 denominator = _reserve1 + amount1WithFee;

        amount0Out = numerator / denominator;

        require(amount0Out >= minAmount0Out, "SLIPPAGE!");

        ERC20(token0).transfer(receiver, amount0Out);

        uint256 newReserve0 = _reserve0 - amount0Out;
        uint256 newReserve1 = _reserve1 + amount1In;
        _updateReserves(newReserve0, newReserve1);

        emit Swap(token1, token0, msg.sender, receiver, amount1In, amount0Out);
    }
}