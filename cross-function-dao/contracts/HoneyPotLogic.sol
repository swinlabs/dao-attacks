pragma solidity ^0.5.0;

contract HoneyPotDataInterface {
   function setBalance(address _address, uint _amount) public payable returns (bool);
   function getBalance(address _address) public view returns (uint _amount);
}

contract HoneyPotLogic {
   // maps addresses to a value and store it in a public variable 
   HoneyPotDataInterface private honeyPotData;


   // constructor
   constructor (address payable _address) payable public {
      honeyPotData = HoneyPotDataInterface(_address);
      put();
   }

   // msg is an information when you call function
   function put() payable public {
      // where the storage of the ether value happens 
         // msg.sender here is the address from the sender
      honeyPotData.setBalance(msg.sender, msg.value);
   }

   function get() public {
      // let addresses to withdraw the value of ether
      bool success;
      bytes memory data;
      (success, data) = msg.sender.call.value(honeyPotData.getBalance(msg.sender))("");

      if (!success) 
      {
         revert("withdrawal failed");
      }
      
      honeyPotData.setBalance(msg.sender, 0);
   }

   // fallback function
   function() external payable {
      revert();
   }
}
