pragma solidity 0.7.5;
pragma abicoder v2;

import "./MultiOwnable.sol";
import "./Approvable.sol";

contract MultiSigWallet is MultiOwnable, Approvable {

    // STATE VARIABLES
    address internal _walletCreator;

    // - Struct type that holds requested transaction details - requestor, recipient, amount, possibly approversToDate (addresses[] or uint)??
    struct TxRequest {
        address requestor;
        address recipient;
        string reason;
        uint amount;
        uint approvals;
        uint id;    // request id
    }
    
    TxRequest[] internal _pendingApprovals;          // array index is request id
    mapping (uint => address) internal _txRequestors;
    mapping (address => mapping (uint => bool)) internal _txApprovals;  // approver => (requestId => approved?)
    
    event TransferSent(address to, uint amount); 

    
    // FUNCTIONS
    // Public & External 
    
    constructor(address[] memory owners, uint minTxApprovals)
        MultiOwnable(owners)
        Approvable(owners, minTxApprovals)
    {
        _walletCreator = msg.sender;
    }
    
    
    function deposit() external payable returns (uint amountDeposited) {
        require (msg.value > 0, "No funds sent to deposit!");
        return(msg.value);
    }
    
        
    function createTransferRequest(address toAddress, string memory reason, uint amount) public onlyAnOwner(msg.sender) returns (uint txId) {
        require(toAddress != address(0), "Recipient is address 0!");
        require(amount > 0, "Transfer amount is 0!");
        
        TxRequest memory newRequest = TxRequest(msg.sender, toAddress, reason, amount, 0, _pendingApprovals.length);
        _pendingApprovals.push(newRequest);
        _txRequestors[newRequest.id] = msg.sender;

        return newRequest.id;
    }
    

    function approveTransferRequest(uint requestId) public onlyAnApprover(msg.sender) {
        // Adds an approval vote to pending request, and triggers transfer if approval vote threshold reached
        require(requestId < _pendingApprovals.length, "No such request id!");
        require(_txApprovals[msg.sender][requestId] != true, "You've already approved!");

        _txApprovals[msg.sender][requestId] = true;
        _pendingApprovals[requestId].approvals++;
        
        if (_pendingApprovals[requestId].approvals >= _minApprovals) {
            
            address sendTo = _pendingApprovals[requestId].recipient;
            uint amountInWei = _pendingApprovals[requestId].amount;

            _deleteTransferRequest(requestId);
            
            // Make the transfer
            // *** TODO ***
            
            // Emit a transferSent event 
            emit TransferSent(sendTo, amountInWei);
        }
        // mapping (address => mapping (uint => bool)) internal _txApprovals;  // approver => (requestId => approved?)
    }
    
    
    function cancelTransferRequest(uint requestId) public onlyAnOwner(msg.sender) {
        require(requestId < _pendingApprovals.length, "No such request id!");
        require(_txRequestors[requestId] == msg.sender, "Not creator of tx request!");
        
        _deleteTransferRequest(requestId);
    }
    
    
    // Useful public functions for testing during development
    function getTransferRequest(uint id) public view returns (TxRequest memory transferRequest) {
        return _pendingApprovals[id];
    }
    
    function getWalletBalance() public view returns (uint balance) {
        return address(this).balance;
    }
    
    function getWalletCreator() public view returns (address) {
        return _walletCreator;
    }
    
    function totalTransferRequests() public view returns (uint) {
        return _pendingApprovals.length;    // note includes deleted requests (i.e cancelled and approved requests)
    }
    
    
    // Internal and Private functions
    
    function _deleteTransferRequest(uint requestId) internal {
        delete _pendingApprovals[requestId];
        delete _txRequestors[requestId];
    }
    
}