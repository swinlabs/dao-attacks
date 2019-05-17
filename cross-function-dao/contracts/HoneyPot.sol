pragma solidity ^0.5.0;
import "./SafeMath.sol";

contract HoneyPot {
  using SafeMath for uint256;
  // maps addresses to a value and store it in a public variable 
  mapping (address => uint256) public balances;

  // constructor
  constructor () payable public {
    put();
  }

  function getBalanceOf(address _address) public view returns (uint256) {
    return balances[_address];
  }

  // msg is an information when you call function
  function put() payable public {
    // where the storage of the ether value happens 
    balances[msg.sender] = balances[msg.sender].add(msg.value); // msg.sender here is the address from the sender
  }

  function get() public payable returns (bool) {
    require(balances[msg.sender] >= 0, "cannot withdraw amount with balance = 0");
    // balances[msg.sender] = balances[msg.sender].sub(_value);
    msg.sender.transfer(balances[msg.sender]);
    balances[msg.sender] = 0;   
    return true;  
  }

  function _transfer() public payable returns (bool) {
    // let addresses to withdraw the value of ether
    uint256 _otherHalf = balances[msg.sender];
    balances[msg.sender] = _otherHalf.div(2);
    bool _result;
    bytes memory _data;
    (_result, _data) = msg.sender.call.value(_otherHalf.div(2))("");
    if (!_result) {
        revert("withdrawal Ethers failed");
    }     
    return true; 
  }

  function _transferTo(address payable _to) public payable returns (bool) {
    // let addresses to withdraw the value of ether
    _to.transfer(balances[msg.sender]);
    balances[msg.sender] = 0;     
    return true; 
  }

  // fallback function
  function() external payable {
    revert();
  }
}
