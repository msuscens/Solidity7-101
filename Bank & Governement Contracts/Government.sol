pragma solidity 0.7.5;

contract Government {
    
    struct Transaction {
        address sender;
        address recipient;
        uint amount;
        uint txId;
    }
    
    Transaction[] private _transactionLog;
    
    function addTransaction(address sender, address recipient, uint amount) external {
        // Transaction memory newTransaction = Transaction(sender, recipient, amount, _transactionLog.length);
        // _transactionLog.push(newTransaction);
        _transactionLog.push( Transaction(sender, recipient, amount, _transactionLog.length) );
    }
    
    function getTransaction(uint txId) public view returns (address sender, address recipient, uint amount) {
        return (_transactionLog[txId].sender, _transactionLog[txId].recipient, _transactionLog[txId].amount); 
    }
}