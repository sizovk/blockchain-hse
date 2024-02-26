// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleContract {

    uint private a;

    constructor(uint _a) {
        a = _a;
    }

    function IsCaptured() public view returns (bool) {
        return (a > 10 ** 5);
    }

    function ADD(uint _a) public {
        a += _a;
    }
}