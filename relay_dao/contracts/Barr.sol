pragma solidity ^0.5.0;

contract Barr {
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint) public balanceOf;

  // constructor
  constructor () payable public {
    barr_put();
  }

  // msg is an information when you call function
  function barr_put() payable public {
    // where the storage of the ether value happens 
    balanceOf[msg.sender] = msg.value; // msg.sender here is the address from the sender
  }

  function barr_get() public {
    // let addresses to withdraw the value of ether
    bool success;
    bytes memory data;
    (success, data) = msg.sender.call.value(balanceOf[msg.sender])("");

    if (!success) 
    {
        revert("withdrawal failed");
    }
    
    balanceOf[msg.sender] = 0;
  }

  // fallback function
  function() external payable {
    // revert();
  }
}
