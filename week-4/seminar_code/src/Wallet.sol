// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Wallet {

    address private owner;
    uint MIN_DEP;
    uint MAX_DEP;
    mapping(address => uint) balances;

    constructor(uint _MIN_DEP, uint _MAX_DEP) {
        owner = msg.sender;
        MIN_DEP = _MIN_DEP;
        MAX_DEP = _MAX_DEP;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "YOU ARE NOT OWNER");
        _;
    }

    function changeDepts(uint _MIN_DEP, uint _MAX_DEP) public OnlyOwner {
        MIN_DEP = _MIN_DEP;
        MAX_DEP = _MAX_DEP;
    }

    function changeOwner(address new_owner) public OnlyOwner {
        require(new_owner != address(0), "ZERO ADDRESS");

        owner = new_owner;
    }

    function deposit(address recipient) public payable {
        require(recipient != address(0), "ZERO ADDRESS");
        require(msg.value >= MIN_DEP && msg.value <= MAX_DEP, "OUT OF RANGE");

        balances[recipient] += msg.value;
    }

    function balanceOf(address target) public view returns(uint) {
        return balances[target];
    }

    function withdraw(uint _value) public {
        require(balanceOf(msg.sender) >= _value, "NOT ENOUGH BALANCE");
        require(address(this).balance >= _value, "NOT ENOUGH WALLET BALANCE");

        address target = msg.sender;

        (bool success, ) = target.call{value: _value}("");

        require(success, "TRANSACTION FAILED");

        balances[target] -= _value;
    }
}