pragma solidity ^0.5.0;

contract HoneyPotData {
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint) private _balances;
  address payable _logicAddress;

  // constructor
  constructor () payable public {
  }

  function addBalance(address _address, uint _amount) external payable returns (bool) {
     _balances[_address] += _amount;
  }

  function subBalance(address _address, uint _amount) external payable returns (bool) {
    require(_balances[_address] >= _amount, "blance of account not enough for sub");
      _logicAddress.call.value(_amount)("");
      _balances[_address] -= _amount;
  }

  function getBalance(address _address) public view returns (uint _amount) {
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
