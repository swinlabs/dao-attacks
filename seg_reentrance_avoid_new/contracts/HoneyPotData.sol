pragma solidity ^0.5.0;

import "./SafeMath.sol";
contract HoneyPotData {
  using SafeMath for uint256;
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint256) private _balances;
  address payable _logicAddress;

  // constructor
  constructor () payable public {
  }

  function addBalance(address _address, uint256 _amount) external payable returns (bool) {
     _balances[_address] = _balances[_address].add(_amount);
     //update balance of logicContract accordingly
     _balances[_logicAddress] = _logicAddress.balance;
  }

  function subBalance(address _address, uint256 _amount) external payable returns (bool) {
    require(_balances[_address] >= _amount, "blance of account not enough for sub");
    _balances[_address] = _balances[_address].sub(_amount);
    //update balance of logic Contract accordingly
    _balances[_logicAddress] = _balances[_logicAddress].sub(_amount);
    //verify the balance of logic Contract
    require(_balances[_logicAddress] == _logicAddress.balance, 
    "inconsistence of state for subBalance");
  }

  function getBalance(address _address) public view returns (uint256 _amount) {
     _amount = _balances[_address];
  }

  function updateLogicAddress(address payable _address) public returns (bool) {
    _logicAddress = _address;
  }

  function getLogicAddress() public view returns (address payable) {
    return _logicAddress;
  }

  // fallback function
  function() external payable {
    // let this contract a receivable ether
    // revert();
  }
}
