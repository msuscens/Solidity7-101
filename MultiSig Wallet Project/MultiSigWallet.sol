pragma solidity 0.7.5;
pragma abicoder v2;

import "./MultiOwnable.sol";
import "./Approvable.sol";

contract MultiSigWallet is MultiOwnable, Approvable {

    // STATE VARIABLES
    address internal _walletCreator;
    uint internal _minTxApprovals;

    // - Struct type that holds requested transaction details - requestor, recipient, amount, possibly approversToDate (addresses[] or uint)??
    // - pendingApprovalRequests: array of  structs (requested transactions) - with array index being used as requestId
    // - openRequestsByOwner : mapping owner's address -> array of transfer request ids (uint[]) 
    
    // - sentTransactions ? (possible nice to have, to keep a record of who approved sent transactions)
    // - rejectedTransactions ? (possible nice to have, similar to above - keep a record of who rejected proposed Txs)
    
    
    // FUNCTIONS
    constructor(address[] memory owners, uint minTxApprovals)
        MultiOwnable(owners)
        Approvable(owners, minTxApprovals)
    {
        _walletCreator = msg.sender;
        _minTxApprovals = minTxApprovals;
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
        
    // - createTransferRequest(toAddress, amount, reason?) onlyOwners
    //     How are other owners notified of transfer requests - events? / transfer Request log? both!
    // - cancelTransferRequest : creator can cancel/delete

    // -   numberPendingTransferRequests : Returns number of open requests
    // -   getPendingTransferRequest(index) : Returns details of specic transfer requests
    
    // - accceptTransferRequest(index) onlyOwners : Adds an approval vote to pending request, and triggers transfer if approval vote threshold reached
    // - declineTransferRequest(index) onlyOwners : Adds a not approved vote to pending request, and rejects request if approval vote threshold can no longer be reached
    
    
}