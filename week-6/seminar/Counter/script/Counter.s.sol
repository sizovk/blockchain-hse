// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Hello {
  bool public done;
  uint256 public size;

  function setHello(address target) public returns (bool) {
    bytes4 selector = bytes4(keccak256("sayHi()"));
    (bool success, bytes memory result) = target.call(abi.encodeWithSelector(selector));

    if (success && keccak256(abi.decode(result, (bytes))) == keccak256(bytes("HelloFromHSE"))) {
      done = true;
    }

    return done;
  }
}

contract HelloContract {
    function sayHi() public pure returns (bytes memory) {
        return bytes("HelloFromHSE");
    }
}

contract CheckScript is Script {

    Hello h = Hello(0x0113Fbc4c376Aa6518d0fD7191226988552Cca36);
    function setUp() public {}

    function run() public {

        uint pk = vm.envUint("PK");
        address me = vm.addr(pk);

        console2.log(me);
        vm.startBroadcast(pk);
        HelloContract myH = HelloContract(0x1386238218F8F0C0fbae50e0AdE65B5A61c9b609);
        //HelloContract myH = new HelloContract();

        console2.log(address(myH));
        bytes4 selector = bytes4(keccak256("sayHi()"));
        (bool success, bytes memory result) = address(myH).call(abi.encodeWithSelector(selector));

        if (success && keccak256(abi.decode(result, (bytes))) == keccak256(bytes("HelloFromHSE"))) {
          console2.log("true");
        } else {
          console2.log("false");
        }

        console2.logString(string(result));
        // console2.log("sayHi: ", string(result));
        h.setHello(address(myH));

        vm.stopBroadcast();
    }
}