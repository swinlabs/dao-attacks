pragma solidity ^0.4.24;

import "./SafeMath.sol";

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract ProxyMultiContracts {
   using SafeMath for uint256;
   //signature of calldata (function - the 4 first bytes)
   address private owner;
   address[] private ctrtAddresses;
   mapping(address => bytes4[]) functionSignatures;

   constructor() public {
      owner = msg.sender;
   }

   function addContract(address _address, bytes4[] _funcSigns) public returns (bool) {
      require(addCtrtAddress(_address) == true, "address must be added successfully");
      setFuncSigns(_address, _funcSigns);
      return true;
   }

   function updateContract(address _existing, address _new, bytes4[] _funcSigns) public returns (bool) {
      updateCtrtAddress(address _existing, address _new);
      setFuncSigns(_new, _funcSigns);
      return true;
   }

   function addCtrtAddress(address _address) public returns (bool result) {
      require(isExistingAddress(_address), "address must not be existing");
      require(_address != address(0), "adding address must be valid");
      ctrtAddresses.push(_address);
      result = true;
   }

   function getCtrtAddresses() public returns (address[] _addresses) {
      _addresses = ctrtAddresses;
   }

   function updateCtrtAddress(address _existing, address _new) public returns (bool result) {
      address memory _addresses = ctrtAddresses;
      require(isExistingAddress == true, "existing address does not exist"); 
      require(_new != address(0), "new address must be valid");
      for (uint256 i = 0; i < ctrtAddresses.length; i++) {
         if (_existing == ctrtAddresses[i]) {
            ctrtAddresses[i] = _new;
            result = true;
            return;
         }
      }   
   }

   function removeCtrtAddress(address _address) public returns (bool result) {
      require(isExistingAddress == true, "removing address must exist");
      address memory _addresses;
      uint256 arrayLength;
      _addresses = contractAddresses();
      for (uint256 i = 0; i < _addresses.length; i++) {
            if (_address == _addresses[i]) {
                contractAddresses[i] = _addresses[arrayLength.sub(1)];
                delete contractAddresses[arrayLength.sub(1)];
                contractAddresses.length = arrayLength.sub(1);
                return true;
            }
        }

   } 

   function isExistingAddress(address _address) public view returns (bool result) {
      address[] memory _addresses = getCtrtAddresses();
      if (_addresses.length == 0) {
         return;
      }
      for (uint i = 0; i < _addresses.length; i++) {
         if (_addresses[i] == _address) {
            result = true;
            break;
         }
      }
   }

   //function to update middleware contract address
   function getFuncSigns(address _address) public view returns(bytes4[]) {
      return functionSignatures[_address];
   }
 
   
   //function to get 
   function setFuncSigns(address _address, bytes4[] _funcSigns) private returns(bool) {
      //how to get all function signatures of all functions of the contract from abiString
      //myContract.methods.myMethod([param1[, param2[, ...]]]).encodeABI()
      functionSignatures[_address] = _funcSigns;
      return true;
   }

   function callDestination(bytes _calldata) private returns (address) {
      //if sinature of function (4 bytes) of _calldata belongs to Erc20, then set the callAddress to erc20
      
   }

   /**
   * @dev Fallback function allowing to perform a delegatecall to the given implementation.
   * This function will return whatever the implementation call returns
   */
   function () payable public {
      //get first 4 bytes of calldataload
      bytes32 _funcSign;
      assembly {
         calldatacopy(0x40, 0, 0x4)
         _funcSign = mload(0x60);
      }

      assembly {
         mstore(0x60,0x60) 
         // let ptr := mload(0x40)              //this is free memory, so mload(0x40) = 0x00
         //get value from address 0x60
         __before := mload(0x60)
      }
      _before = __before;
      assembly {
         //get data size
         // __callDataSize := calldatasize
         sstore(_callDataSize_slot, calldatasize)
         //ENHANCE THE USE OF MEMORY
         let ptr := add(msize, 20)   //copy to the next to the last item of memory, to assure no overide anything
         calldatacopy(ptr, 0, calldatasize)  //copy to memory: memory = [0x00:0x00+calldatasize=>msg.data[0:calldatasize]]
         // __callDataLoad := calldataload(0x0)
         //store data load
         sstore(_callDataLoad_slot, calldataload(0x0))
         let result := delegatecall(gas, _currentAddress, ptr, calldatasize, 0, 0)
         //get value in this address to see if we get it from mint call function
         __during := mload(0x60)
         sstore(_during_slot, __during)
         let size := returndatasize
         let ptr_return := add(msize, 20)   //copy to the next to the last item of memory, to assure no overide anything
         returndatacopy(ptr_return, 0, size)
         //store memory size
         sstore(proxyMemorySize_slot, msize)
         __returnDataOneByte := mload(ptr_return)
         sstore(_returnDataLoad_slot, __returnDataOneByte)
         //finally get the return data
         __after := mload(0x320)
         sstore(_after_slot, __after)
         // __callDataSize := mload(0x2000)
         switch result
         case 0 { revert(ptr_return, size) }
         default { return(ptr_return, size) }
      }
      // _after = __after;
      // _callDataSize = __callDataSize;
      // _callDataLoad = __callDataLoad;
   }
}
   