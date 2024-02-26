// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Wallet} from "../src/Wallet.sol";

contract WalletScript is Script {
    function setUp() public {}

    function run() public {
        uint pk = vm.envUint("PRIVATE_KEY");
        address me = 0x37661190318D938e46900D766ee45025105EA583;

        vm.startBroadcast(pk);

        Wallet wallet = new Wallet(0, 500);

        wallet.deposit{value: 50}(me);

        vm.stopBroadcast();

    }
}
