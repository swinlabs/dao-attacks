pragma solidity ^0.5.0;

/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
  uint256 private memoryAt0x40;
  
  uint256 private memoryAt0x60;
  bytes32 private memoryAt0x80;  //default value of memory address at 0x40
  bytes32 private memoryAt0x80After;
  uint256 private _msize;

  function getMemoryAt0x40() public view returns (uint256) {
    return memoryAt0x40;
  }

  function getMemoryAt0x80After() public view returns (bytes32) {
    return memoryAt0x80After;
  }

  function getMemoryAt0x60() public view returns (uint256) {
    return memoryAt0x60;
  }

  function getMemoryAt0x80() public view returns (bytes32) {
    return memoryAt0x80;
  }

  function getMsize() public view returns (uint256) {
    return _msize;
  }
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
    // uint256 _testValue1 = 10;
    // uint256 _testValue2 = 20;
    // uint256 _testValue3 = 30;
    // uint256 _testValue4 = 40;
    // uint256 _testValue5 = 50;
    // uint256 _testValue6 = 60;
    // uint256 _testValue7 = 70;
    // uint256 _testValue8 = 80;
    // uint256 _testValue9 = 90;

    assembly {
      // _testValue1 := 10
      // _testValue2 := 20
      // _testValue3 := 30
      // _testValue4 := 40
      // _testValue5 := 50
      // sstore(_msize_slot, msize)
      sstore(memoryAt0x40_slot, mload(0x40))
      sstore(memoryAt0x60_slot, mload(0x60))
      sstore(memoryAt0x80_slot, mload(0x80))
      //get data size
      let ptr := mload(0x40)   //copy to the next to the last item of memory, to assure no overide anything
      calldatacopy(ptr, 0, calldatasize)  //copy to memory: memory = [0x00:0x00+calldatasize=>msg.data[0:calldatasize]]
      sstore(_msize_slot, msize)
      sstore(memoryAt0x80After_slot, mload(0x80))
      let result := delegatecall(gas, _currentAddress, ptr, calldatasize, 0, 0)
      //get value in this address to see if we get it from mint call function

      let size := returndatasize
      let ptr_return := mload(0x40)   //copy to the next to the last item of memory, to assure no overide anything
      returndatacopy(ptr_return, 0, size)
      switch result
      case 0 { revert(ptr_return, size) }
      default { return(ptr_return, size) }
    }
  }
}
