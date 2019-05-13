pragma solidity ^0.5.0;

import "./SafeMath.sol";

contract ProxyMultiInterface {
   function getCtrtAddresses() public view returns (address[] memory _addresses);
   //function to update middleware contract address
   function getFuncSigns(address _address) public view returns(bytes4[] memory);   
   //function to get 
   function callDestination(bytes4 _f_sig) public view returns (address _contract);
}

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract DataProxy {
   using SafeMath for uint256;
   //signature of calldata (function - the 4 first bytes)
   address private owner;
   bytes4 private funcSignature;
   ProxyMultiInterface private proxyMulti;

   constructor(address _proxyMultiAddr) public {
      owner = msg.sender;
      proxyMulti = ProxyMultiInterface(_proxyMultiAddr);
   }

   function getFuncSignature() public view returns (bytes4) {
      return funcSignature;
   }

   function _callDestination(bytes4 _f_sig) private view returns (address _contract) {
      _contract = proxyMulti.callDestination(_f_sig);
   }

   /**
   * @dev Fallback function allowing to perform a delegatecall to the given implementation.
   * This function will return whatever the implementation call returns
   */
   function () payable external {
      //WHERE TO DECLARE MEMORY VARIABLE
      address _currentAddress;
      bytes32 _bytes32Buffer;
      bytes4 f_sig;
      //do not define or declare any memory variable outside this box.
      assembly {
         let ptr := msize   //copy to the next to the last item of memory, to assure no overide anything
         calldatacopy(ptr, 0, 4)  //copy to memory: 
         _bytes32Buffer := mload(ptr)
      }
      f_sig = bytes4(_bytes32Buffer);
      funcSignature = f_sig;
      _currentAddress = _callDestination(f_sig);
      require(_currentAddress != address(0), "contract address must not be 0x0");
      assembly {
         let ptr_call := msize
         calldatacopy(ptr_call, 0, calldatasize)
         let result := delegatecall(gas, _currentAddress, ptr_call, calldatasize, 0, 0)
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
   