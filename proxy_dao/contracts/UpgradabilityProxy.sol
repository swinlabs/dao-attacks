pragma solidity ^0.5.0;

import './Proxy.sol';

/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradabilityProxy is Proxy {
  /**
   * @dev This event will be emitted every time the implementation gets upgraded
   * @param implementation representing the address of the upgraded implementation
   */
  event Upgraded(address indexed implementation);

  // Storage position which store the address of the current logic contract
  bytes32 private constant storagePositionOfContract = keccak256("Just a constant string to return a constant storage position");

  /**
   * @dev Constructor function
   */
  constructor(address _proxyLogicAddress) public {
    _setContractAddress(_proxyLogicAddress);
  }

  /** GET ADDRESS OF THE CURRENT IMPLEMENTATION
   * @dev Tells the address of the current implementation
   * @return address of the current implementation
   */
  function getContractdAddress() public view returns (address _currentDeployedAddress) {
    bytes32 position = storagePositionOfContract;
    assembly {
      _currentDeployedAddress := sload(position)
    }
  }

  /**
   * @dev Sets the address of the current implementation
   * @param _newContractAddress address representing the new implementation to be set
   */
  function _setContractAddress(address _newContractAddress) internal {
    bytes32 position = storagePositionOfContract;
    assembly {
      sstore(position, _newContractAddress)
    }
  }

  /**
   * @dev Upgrades the implementation address
   * @param newPosition representing the address of the new implementation to be set
   */
  function _upgradeTo(address newPosition) public {
    address currentImplementation = getContractdAddress();
    require(currentImplementation != newPosition);
    _setContractAddress(newPosition);
    emit Upgraded(newPosition);
  }

  //KEEP IN MIND THERE IS FALLBACK FUNCTION INHERIT FROM PROXY CONTRACT
}
