pragma solidity ^0.5.0;

contract HoneyPotDataInterface {
   function setBalance(address _address, uint _amount) external payable returns (bool);
   function getBalance(address _address) public view returns (uint _amount);
}

contract HoneyPotLogic {
   // maps addresses to a value and store it in a public variable 
   HoneyPotDataInterface private honeyPotData;
   address payable _dataAddress;


   // constructor
   constructor (address payable _address) payable public {
      _dataAddress = _address;
      honeyPotData = HoneyPotDataInterface(_dataAddress);
      // put();
   }

   // msg is an information when you call function
   function put() payable public {
      // where the storage of the ether value happens 
         // msg.sender here is the address from the sender
      uint _amount = msg.value;
      address payable _sender = msg.sender;     
      honeyPotData.setBalance(_sender, _amount);
   }

   function get() public {
      // let addresses to withdraw the value of ether
      // bool success;
      // bytes memory data;
      // (success, data) = msg.sender.call.value(honeyPotData.getBalance(msg.sender))("");
      // if (!success) 
      // {
      //    revert("withdrawal failed");
      // }
      address payable _sender = msg.sender;
      uint _amount = honeyPotData.getBalance(msg.sender);
      _sender.send(_amount);
      
      honeyPotData.setBalance(msg.sender, 0);
   }

   function getDataAddress() public view returns (address payable) {
      return _dataAddress;
   }

   // fallback function
   function() external payable {
      revert();
   }
}
