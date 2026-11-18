// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract BlockTest is Test {

    function setUp() public {

    }

    function test_1() public {
        
        uint256 a = 25;

        uint256 b = Math.sqrt(a);

        console2.log(b);

    }
}
