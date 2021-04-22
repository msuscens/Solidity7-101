pragma solidity 0.7.5;

import "./Ownable.sol";
import "./Destroyable.sol";

interface IGovernment {
    function addTransaction(address sender, address recipient, uint amount) external;
}


contract Bank is Ownable, Destroyable {
    
    mapping(address => uint) balance;
    
    event depositDone(uint amount, address indexed depositedTo);
    
    IGovernment instanceGovernment = IGovernment(0xDA0bab807633f07f013f94DD0E6A4F96F8742B53);
    
    
    function deposit() public payable returns (uint)  {
        balance[msg.sender] += msg.value;
        emit depositDone(msg.value, msg.sender);
        return balance[msg.sender];
    }
    
    function withdraw(uint amount) public onlyOwner returns (uint){
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        msg.sender.transfer(amount);
        return balance[msg.sender];
    }
    
    function getBalance() public view returns (uint){
        return balance[msg.sender];
    }
    
    function transfer(address recipient, uint amount) public {
        require(balance[msg.sender] >= amount, "Balance not sufficient");
        require(msg.sender != recipient, "Don't transfer money to yourself");
        
        uint previousSenderBalance = balance[msg.sender];
        
        _transfer(msg.sender, recipient, amount);
        
        instanceGovernment.addTransaction(msg.sender, recipient, amount);
                
        assert(balance[msg.sender] == previousSenderBalance - amount);
    }
    
    function _transfer(address from, address to, uint amount) private {
        balance[from] -= amount;
        balance[to] += amount;
    }
    
}