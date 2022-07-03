// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  mapping (address => bool) private _owners;
  address private _owner;

  event OwnershipTransferred(address indexed initiator, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owners[msgSender] = true;
    _owner = msgSender;

    emit OwnershipTransferred(address(0), msgSender);
  }

  function _addOwner(address newOwner) private {
    _owners[newOwner] = true;

    emit OwnershipTransferred(_msgSender(), newOwner);
  }

  function _removeOwner(address addr) private {
      _owners[addr] = false;
      
      if(addr == _owner) {
          _owner = _msgSender();
      }
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  function isOwner(address addr) public view returns (bool result) {
      return _owners[addr];
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owners[_msgSender()], "Ownable: caller is not the owner");
    _;
  }

  function addOwner(address addr) public onlyOwner {
      _addOwner(addr);
  }


  function removeOwner(address addr) public onlyOwner {
      _removeOwner(addr);
  }
}