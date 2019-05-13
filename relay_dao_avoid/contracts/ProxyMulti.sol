pragma solidity ^0.5.0;

import "./SafeMath.sol";
/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract ProxyMulti {
   using SafeMath for uint256;
   //signature of calldata (function - the 4 first bytes)
   address private owner;
   address private dataAddr;
   address[] private ctrtAddresses;
   mapping(address => bytes4[]) functionSignatures;

   constructor(address _foo, address _bar) public {
      owner = msg.sender;
      addCtrtAddress(_foo);
      addCtrtAddress(_bar);
   }

   function setDataCtrtAddress(address _dataAddr) public returns (bool _result) {
      dataAddr = _dataAddr;
      _result = true;
   }

   function getDataCtrtAddress() public view returns (address _result) {
      _result = dataAddr;
   }

   function addContract(address _address, bytes4[] memory _funcSigns) public returns (bool) {
      // require(addCtrtAddress(_address) == true, "address must be added successfully");
      setFuncSigns(_address, _funcSigns);
      return true;
   }

   function updateContract(address _existing, address _new, bytes4[] memory _funcSigns) public returns (bool) {
      updateCtrtAddress(_existing, _new);
      setFuncSigns(_new, _funcSigns);
      return true;
   }

   function addCtrtAddress(address _address) public returns (bool result) {
      require(isExistingAddress(_address) == false, "address must not be existing");
      require(_address != address(0), "adding address must be valid");
      ctrtAddresses.push(_address);
      result = true;
   }

   function getCtrtAddresses() public view returns (address[] memory _addresses) {
      _addresses = ctrtAddresses;
   }

   function updateCtrtAddress(address _existing, address _new) public returns (bool result) {
      // address[] memory _addresses = ctrtAddresses;
      require(isExistingAddress(_existing) == true, "existing address does not exist"); 
      require(_new != address(0), "new address must be valid");
      for (uint256 i = 0; i < ctrtAddresses.length; i++) {
         if (_existing == ctrtAddresses[i]) {
            ctrtAddresses[i] = _new;
            result = true;
            break;
         }
      }   
   }

   function removeCtrtAddress(address _address) public returns (bool result) {
      require(isExistingAddress(_address) == true, "removing address must exist");
      address[] memory _addresses;
      uint256 arrayLength;
      _addresses = getCtrtAddresses();
      for (uint256 i = 0; i < _addresses.length; i++) {
            if (_address == _addresses[i]) {
                ctrtAddresses[i] = _addresses[arrayLength.sub(1)];
                delete ctrtAddresses[arrayLength.sub(1)];
                ctrtAddresses.length = arrayLength.sub(1);
                return true;
            }
        }

   } 

   function isExistingAddress(address _address) public view returns (bool result) {
      address[] memory _addresses = getCtrtAddresses();
      if (_addresses.length != 0) {
         for (uint i = 0; i < _addresses.length; i++) {
            if (_addresses[i] == _address) {
               result = true;
               break;
            }
         }
      }
   }

   //function to update middleware contract address
   function getFuncSigns(address _address) public view returns(bytes4[] memory) {
      return functionSignatures[_address];
   }
 
   
   //function to get 
   function setFuncSigns(address _address, bytes4[] memory _funcSigns) private returns(bool) {
      //how to get all function signatures of all functions of the contract from abiString
      //myContract.methods.myMethod([param1[, param2[, ...]]]).encodeABI()
      functionSignatures[_address] = _funcSigns;
      return true;
   }

   function callDestination(bytes4 _f_sig) public view returns (address _contract) {
      //if sinature of function (4 bytes) of _calldata belongs to Erc20, then set the callAddress to erc20
      address[] memory _addresses = getCtrtAddresses();
      require(_addresses.length != 0, "require array of at least one contract");
      for (uint i = 0; i < _addresses.length; i++) {
         bytes4[] memory _f_sigs = getFuncSigns(_addresses[i]);
         for (uint j = 0; j < _f_sigs.length; j++) {
            if (_f_sig == _f_sigs[j]) {
               _contract = _addresses[i];
               break;
            }
         }
      }
   }

   /**
   * @dev Fallback function allowing to perform a delegatecall to the given implementation.
   * This function will return whatever the implementation call returns
   */
   function () payable external {
      //WHERE TO DECLARE MEMORY VARIABLE
      address _dataAddress = getDataCtrtAddress();
      require(_dataAddress != address(0), "data contract address must not 0x0");
      assembly {
         //call value = CALLVALUE
         let ptr_call := msize
         calldatacopy(ptr_call, 0, calldatasize)
         let result := call(gas, _dataAddress, div(callvalue, 2), ptr_call, calldatasize, 0, 0)
         // let result := delegatecall(gas, _dataAddress, ptr_call, calldatasize, 0, 0)
         //get value in this address to see if we get it from mint call function

         let size := returndatasize
         let ptr_return := msize   //copy to the next to the last item of memory, to assure no overide anything
         returndatacopy(ptr_return, 0, size)
         switch result
         case 0 { revert(ptr_return, size) }
         default { return(ptr_return, size) }
      }      
   }
}
   