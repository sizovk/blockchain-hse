// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MyDEX} from "../src/DEX.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(string memory name_, string memory symbol_, uint256 initialSupply) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract DEXTest is Test {
    MyDEX dex;
    MyToken token0;
    MyToken token1;

    function setUp() public {
        token0 = new MyToken("token0", "t0", 100 ether);
        token1 = new MyToken("token1", "t1", 500 ether);

        dex = new MyDEX(address(token0), address(token1));

        token0.approve(address(dex), 100 ether);
        token1.approve(address(dex), 500 ether);
        dex.addLiquidity(100 ether, 500 ether, address(this));
    }

    function testBase() public {
        (uint256 r0, uint256 r1) = dex.getReserves();
        console2.log(r0);
        console2.log(r1);

        address swapper = address(100);
        token0.mint(swapper, 5 ether);

        vm.startPrank(swapper);
        token0.approve(address(dex), 5 ether);

        dex.SwapZeroToOne(5 ether, 0, swapper);

        vm.stopPrank();

        (r0, r1) = dex.getReserves();
        console2.log(r0);
        console2.log(r1);

        console2.log(token1.balanceOf(swapper));
    }   
}