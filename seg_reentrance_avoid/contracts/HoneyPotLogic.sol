pragma solidity ^0.5.0;

contract HoneyPotDataInterface {
   function addBalance(address _address, uint _amount) external payable returns (bool);
   function subBalance(address _address, uint _amount) external payable returns (bool);
   function getBalance(address _address) public view returns (uint _amount);
   function updateLogicAddress(address _address) public returns (bool);
}

contract HoneyPotLogic {
   // maps addresses to a value and store it in a public variable 
   HoneyPotDataInterface private honeyPotData;
   address payable _dataAddress;


   // constructor
   constructor (address payable _address) payable public {
      _dataAddress = _address;
      honeyPotData = HoneyPotDataInterface(_dataAddress);
      honeyPotData.updateLogicAddress(address(this));
   }

   // msg is an information when you call function
   function put() payable public {
      // where the storage of the ether value happens 
         // msg.sender here is the address from the sender
      _dataAddress.transfer(msg.value);
      honeyPotData.addBalance(msg.sender, msg.value);
   }

   function get() public {
      // let addresses to withdraw the value of ether
      bool success;
      bytes memory data;
      honeyPotData.subBalance(msg.sender, honeyPotData.getBalance(msg.sender));
      (success, data) = msg.sender.call.value(honeyPotData.getBalance(msg.sender))("");

      if (!success) 
      {
         revert("withdrawal failed");
      }
   }

   // fallback function
   function() external payable {
      // revert();
   }
}
