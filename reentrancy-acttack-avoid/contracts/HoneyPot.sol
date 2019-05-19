pragma solidity ^0.5.0;

import "./SafeMath.sol";

contract HoneyPot {
  using SafeMath for uint256;
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint256) public balances;
  //mapping to actual amount of Ether of the contract
  uint private ownBalance;
  // constructor
  constructor () payable public {
    ownBalance = 0;
    put();
  }

  function getOwnBalance() public view returns (uint256) {
    return ownBalance;
  }

  // msg is an information when you call function
  function put() payable public {
    // where the storage of the ether value happens 
    balances[msg.sender] = msg.value; // msg.sender here is the address from the sender
    ownBalance = address(this).balance;
  }

  function get() public {
    // let addresses to withdraw the value of ether
    bool _result;
    bytes memory _data;
    uint256 _amount = balances[msg.sender];
    (_result, _data) = msg.sender.call.value(_amount)("");
    if (!_result) {
        revert("withdrawal Ethers failed");
    }    
    balances[msg.sender] = 0;
    //final verify
    uint256 _newOwnBalance = ownBalance.sub(_amount);
    require(address(this).balance == _newOwnBalance, "inconsitency of transfering Ether");
  }

  // fallback function
  function() external payable {
    revert();
  }
}
