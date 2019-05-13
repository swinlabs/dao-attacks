pragma solidity ^0.5.0;

contract Fool {
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint) public balances;

  // constructor
  constructor () payable public {
    fool_put();
  }

  // msg is an information when you call function
  function fool_put(address _address) payable public {
    // where the storage of the ether value happens 
    balances[_address] += msg.value; // msg.sender here is the address from the sender
  }

  function fool_get(address _address) public {
    // let addresses to withdraw the value of ether
    bool success;
    bytes memory data;
    // (success, data) = msg.sender.call.value(balances[msg.sender])("");
    (success, data) = msg.sender.call.value(balances[msg.sender])("");

    if (!success) 
    {
        revert("withdrawal from Fool failed");
    }
    
    balances[msg.sender] = 0;
  }

  function getBalanceOf(address _address) public view returns (uint) {
    return balances[_address];
  }

  // fallback function
  function() external payable {
    // revert();
  }
}
