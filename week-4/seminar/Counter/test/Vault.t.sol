// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault vault;
    address deployer = address(1500);

    function setUp() public {
        
        vm.startPrank(deployer);

        vault = new Vault(100, 150);

        vm.stopPrank();

    }

    function test_1() public {
        
        vm.prank(deployer);
        uint256 num2 = vault.getNumber2();

        vault.setNumber(num2);
        vault.trySolve();
        console.log(vault.flag());
    }
}
