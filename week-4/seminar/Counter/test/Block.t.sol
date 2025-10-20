// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

contract BlockTest is Test {

    function setUp() public {

    }

    function test_1() public {
        
        uint256 _block = block.number;

        console2.log(uint256(blockhash(block.number - 1)));

        vm.roll(_block + 1000);

        console2.log(uint256(blockhash(block.number)));

    }
}
