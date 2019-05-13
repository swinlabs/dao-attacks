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
   address[] private ctrtAddresses;
   mapping(address => bytes4[]) functionSignatures;

   constructor(address _foo, address _bar) public {
      owner = msg.sender;
      addCtrtAddress(_foo);
      addCtrtAddress(_bar);
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

   function callDestination(bytes4 _f_sig) private view returns (address _contract) {
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
      address _destAddr;
      bytes32 _bytes32Buffer;
      bytes4 f_sig;
      assembly {
         let ptr := mload(0x40)   //memory location to copy
         calldatacopy(ptr, 0, 4)  //copy 4 bytes to memory: 
         _bytes32Buffer := mload(ptr)
      }
      f_sig = bytes4(_bytes32Buffer); //get signature of function
      _destAddr = callDestination(f_sig);
      require(_destAddr != address(0), "contract address must valid");
      assembly {
         let _ptr := msize //memory location to copy
         let _size := calldatasize
         if slt(_size, 64) {_ptr := mload(0x40)}
         calldatacopy(_ptr, 0, _size)
         let result := delegatecall(gas, _destAddr, _ptr, _size, 0, 0)
         let size := returndatasize
         let ptr_return := msize   //copy to first free memory
         returndatacopy(ptr_return, 0, size)
         switch result
         case 0 { revert(ptr_return, size) }
         default { return(ptr_return, size) }
      }       
   }
}
   