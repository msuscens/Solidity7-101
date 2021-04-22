//  Assignment: Write a Destroyable contract, which will allow any
// contract inheriting from it to call a function to self destruct.
// Obviously, this action should only be available for the contract owner.

pragma solidity 0.7.5;

import "./Ownable.sol";


contract Destroyable is Ownable {
    
    function destroyContract() public onlyOwner {
        selfdestruct(msg.sender);
    }
    
}