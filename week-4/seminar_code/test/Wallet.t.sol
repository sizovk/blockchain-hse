// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet(0, 5130513);
    }

    function test_1() public {
        address me = 0x37661190318D938e46900D766ee45025105EA583;
        vm.deal(me, 10 ** 18);

        console.log(address(wallet).balance);
        console.log(me.balance);
        
        wallet.deposit{value: 10}(me);
        
        vm.prank(me);
        wallet.withdraw(5);
        vm.stopPrank();
        
        console.log(address(wallet).balance);
        console.log(me.balance);

    }
}
