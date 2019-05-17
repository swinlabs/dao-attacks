pragma solidity ^0.5.0;

contract HoneyPot {
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint) public balances;

  // constructor
  constructor () payable public {
    put();
  }

  // msg is an information when you call function
  function put() payable public {
    // where the storage of the ether value happens 
    balances[msg.sender] = msg.value; // msg.sender here is the address from the sender
  }

  function get() public {
    // let addresses to withdraw the value of ether
    bool _result;
    bytes memory _data;
    (_result, _data) = msg.sender.call.value(balances[msg.sender])("");
    if (!_result) {
        revert("withdrawal Ethers failed");
    }    
    balances[msg.sender] = 0;
  }

  // fallback function
  function() external payable {
    revert();
  }
}
