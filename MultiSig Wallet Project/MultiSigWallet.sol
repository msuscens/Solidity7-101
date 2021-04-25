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
    
    TxRequest[] internal _txRequests;  // array's index == request id
    mapping (uint => address) internal _txRequestors;
    mapping (address => mapping (uint => bool)) internal _txApprovals;
        // approver => (requestId => approval?)
    
    event TransferSent(address to, uint amount); 

    // FUNCTIONS
    // Public & External functions
    
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
    
        
    function createTransferRequest(
        address toAddress,
        string memory reason,
        uint amountWei
    )
        public
        onlyAnOwner
        returns (uint txId)
    {
        require(toAddress != address(0), "Recipient is address 0!");
        require(toAddress != address(this), "Recipeint is this wallet!");
        require(amountWei > 0, "Transfer amount is 0!");
        
        TxRequest memory newRequest =
            TxRequest(
                msg.sender,
                toAddress,
                reason,
                amountWei,
                0,
                _txRequests.length
            );
        _txRequests.push(newRequest);
        _txRequestors[newRequest.id] = msg.sender;

        return newRequest.id;
    }
    

    function approveTransferRequest(uint requestId)
        public
        onlyAnApprover
    {
        require(requestId < _txRequests.length, "No such request id!");
        require(
            _txApprovals[msg.sender][requestId] != true,
            "Already given approval!"
        );
        require(
            address(this).balance >= _txRequests[requestId].amount,
            "Insufficient funds for payment!"
        ); // NB.Gas cost not accounted for

        _txApprovals[msg.sender][requestId] = true;
        _txRequests[requestId].approvals++;
        
        if (_txRequests[requestId].approvals >= _minApprovals) {
            _makeApprovedTransfer(requestId);
        }
    }
    
    
    function cancelTransferRequest(uint requestId) public onlyAnOwner {
        require(requestId < _txRequests.length, "No such request id!");
        require(
            _txRequestors[requestId] == msg.sender,
            "Not transfer creator!"
        );
        _deleteTransferRequest(requestId);
    }
    

    // Internal and private functions
    
    function _deleteTransferRequest(uint requestId) internal {
        delete _txRequests[requestId];
        delete _txRequestors[requestId];
    }
    
    
    function _makeApprovedTransfer(uint requestId) internal {
        address sendTo = _txRequests[requestId].recipient;
        uint amountInWei = _txRequests[requestId].amount;
        _deleteTransferRequest(requestId);

        _transfer(sendTo, amountInWei);
            
        emit TransferSent(sendTo, amountInWei);
    }
            
    
    function _transfer(address sendTo, uint amountInWei) internal {
        address payable to = address(uint160(sendTo));
        to.transfer(amountInWei);
    }
    

    // Functions for Developer testing 

    function getTransferRequest(uint id)
        public
        view
        returns (TxRequest memory transferRequest)
    {
        return _txRequests[id];
    }
    
    function getWalletBalance() public view returns (uint balance) {
        return address(this).balance;
    }
    
    function getWalletCreator() public view returns (address) {
        return _walletCreator;
    }
    
    function totalTransferRequests() public view returns (uint) {
        return _txRequests.length; // Includes cancelled & approved requests
    }
}