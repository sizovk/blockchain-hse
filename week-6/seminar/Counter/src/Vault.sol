// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Vault {
    address owner;

    uint256 public number;
    uint256 private number2;
    bool public flag;

    constructor(uint256 num1, uint256 num2) {
        owner = msg.sender;
        number = num1;
        number2 = num2;
        flag = false;
    }

    function getNumber() external view returns(uint256) {
        return number;
    }

    function getNumber2() external view returns(uint256) {
        require(msg.sender == owner, "you must be the owner");
        return number2;
    }

    function setNumber(uint256 _number) external {
        number = _number;
    }

    function trySolve() external {
        require(number == number2, "wrong");
        flag = true;
    }

}
