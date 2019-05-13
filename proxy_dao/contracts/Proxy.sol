pragma solidity ^0.5.0;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {

  /**
  * THE IMPLEMENT THIS IN ORDER TO AVOID UNDEFINDED WHEN FALLBACK FUNCTION CALL IT FROM PARRENT CONTRACT
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function getContractdAddress() public view returns (address);

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable external {
    address _currentAddress = getContractdAddress();
    require(_currentAddress != address(0));


    assembly {
      //get data size
      let ptr := msize   //copy to the next to the last item of memory, to assure no overide anything
      calldatacopy(ptr, 0, calldatasize)  //copy to memory: memory = [0x00:0x00+calldatasize=>msg.data[0:calldatasize]]

      let result := delegatecall(gas, _currentAddress, ptr, calldatasize, 0, 0)
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
