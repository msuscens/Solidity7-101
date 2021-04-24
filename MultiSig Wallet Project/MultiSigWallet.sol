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
    
    // - openRequestsByOwner : mapping owner's address -> array of transfer request ids (uint[]) 
    
    // - sentTransactions ? (possible nice to have, to keep a record of who approved sent transactions)
    // - rejectedTransactions ? (possible nice to have, similar to above - keep a record of who rejected proposed Txs)
    
    
    // FUNCTIONS
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
    
    // Useful functions for testing
    function getWalletBalance() public view returns (uint balance) {
        return address(this).balance;
    }
    
    function getWalletCreator() public view returns (address) {
        return _walletCreator;
    }
    
        
    function createTransferRequest(address toAddress, string memory reason, uint amount) public onlyAnOwner(msg.sender) returns (uint txId) {
        require(toAddress != address(0), "Recipient is address 0!");
        require(amount > 0, "Transfer amount is 0!");
        
        TxRequest memory newRequest = TxRequest(msg.sender, toAddress, reason, amount, 0, _pendingApprovals.length);
        _pendingApprovals.push(newRequest);
        _txRequestors[newRequest.id] = msg.sender;

        return newRequest.id;
    }
    
    function cancelTransferRequest(uint requestId) public {
        require(requestId < _pendingApprovals.length, "No such request id!");
        require(_txRequestors[requestId] == msg.sender, "Not owner of tx request!");
        
        delete _pendingApprovals[requestId];
        delete _txRequestors[requestId];
    }
    
    function numberTransferRequests() public view returns (uint) {
        return _pendingApprovals.length;    // note includes cancelled requests
    }
    
    function getTransferRequest(uint id) public view returns (TxRequest memory transferRequest) {
        return _pendingApprovals[id];
    }
    
    
    // - accceptTransferRequest(index) onlyOwners : Adds an approval vote to pending request, and triggers transfer if approval vote threshold reached
    // - declineTransferRequest(index) onlyOwners : Adds a not approved vote to pending request, and rejects request if approval vote threshold can no longer be reached
    
    
}