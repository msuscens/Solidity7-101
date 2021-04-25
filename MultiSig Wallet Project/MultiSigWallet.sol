pragma solidity 0.7.5;
pragma abicoder v2;

import "./MultiOwnable.sol";
import "./Approvable.sol";

contract MultiSigWallet is MultiOwnable, Approvable {

    // STATE VARIABLES
    address internal _walletCreator;

    struct TxRequest {
        address requestor;
        address recipient;
        string reason;
        uint amount;
        uint approvals;
        uint id;    // request id
    }
    
    TxRequest[] internal _pendingApprovals;                             // array index is request id
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
    
        
    function createTransferRequest(address toAddress, string memory reason, uint amount)
        public
        onlyAnOwner(msg.sender)
        returns (uint txId)
    {
        require(toAddress != address(0), "Recipient is address 0!");
        require(toAddress != address(this), "Recipeint is this wallet!");
        require(amount > 0, "Transfer amount is 0!");
        
        TxRequest memory newRequest = TxRequest(msg.sender, toAddress, reason, amount, 0, _pendingApprovals.length);
        _pendingApprovals.push(newRequest);
        _txRequestors[newRequest.id] = msg.sender;

        return newRequest.id;
    }
    

    function approveTransferRequest(uint requestId) public onlyAnApprover(msg.sender) {
        require(requestId < _pendingApprovals.length, "No such request id!");
        require(_txApprovals[msg.sender][requestId] != true, "You've already approved!");
        require(address(this).balance >= _pendingApprovals[requestId].amount,
            "Insufficient funds for payment!"); //NB.Gas cost not accounted for

        _txApprovals[msg.sender][requestId] = true;
        _pendingApprovals[requestId].approvals++;
        
        if (_pendingApprovals[requestId].approvals >= _minApprovals) {
            _makeApprovedTransfer(requestId);
        }
    }
    
    
    function cancelTransferRequest(uint requestId) public onlyAnOwner(msg.sender) {
        require(requestId < _pendingApprovals.length, "No such request id!");
        require(_txRequestors[requestId] == msg.sender, "Not creator of tx request!");
        
        _deleteTransferRequest(requestId);
    }
    
    
    // Useful development testing (public) functions
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
        return _pendingApprovals.length;    // NB. Includes deleted requests (i.e cancelled and approved requests)
    }
    
    
    // Internal and private functions
    
    function _deleteTransferRequest(uint requestId) internal {
        delete _pendingApprovals[requestId];
        delete _txRequestors[requestId];
    }
    
    
    function _makeApprovedTransfer(uint requestId) internal {
        address sendTo = _pendingApprovals[requestId].recipient;
        uint amountInWei = _pendingApprovals[requestId].amount;
        _deleteTransferRequest(requestId);

        _transfer(sendTo, amountInWei);
            
        emit TransferSent(sendTo, amountInWei);
    }
            
    
    function _transfer(address sendTo, uint amountInWei) internal {
        address payable to = address(uint160(sendTo));
        to.transfer(amountInWei);
    }
    
}