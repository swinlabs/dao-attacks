pragma solidity ^0.5.0;

contract HoneyPotData {
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint) private _balances;

  // constructor
  constructor () payable public {
  }

  function setBalance(address _address, uint _amount) external payable returns (bool) {
     _balances[_address] = _amount;
  }

  function getBalance(address _address) public view returns (uint _amount) {
     _amount = _balances[_address];
  }

  // fallback function
  function() external payable {
    // revert();
  }
}
