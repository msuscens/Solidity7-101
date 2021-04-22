Project Introduction

Project - Multisig Wallet
In this project, you should build a Multisig Wallet Smart Contract.
A multisig wallet is a wallet where multiple "signatures" or approvals
are needed for an outgoing transfer to take place. As an example, I could
create a multisig wallet with me and my 2 friends. I configure the wallet
such that it requires at least 2 of us to sign any transfer before it is 
valid. Anyone can deposit funds into this wallet. But as soon as we want 
to spend funds, it requires 2/3 approvals.

Here are the requirements of the smart contract wallet you will be building

- Anyone should be able to deposit ether into the smart contract

- The contract creator should be able to input 
    (1): the addresses of the owners and
    (2): the numbers of approvals required for a transfer, in the constructor.
        For example, input 3 addresses and set the approval limit to 2. 

- Anyone of the owners should be able to create a transfer request. The 
creator of the transfer request will specify what amount and to what address
the transfer will be made.

- Owners should be able to approve transfer requests.

- When a transfer request has the required approvals, the transfer should be sent. 


Please post any questions and answers regarding the Multisig Wallet Project here:

https://forum.ivanontech.com/t/project-multisig-wallet/27222


___________________________________________________________________________________

 My Initial Thoughts / My Planning for development:
 
 MultiSigWallet contract: Constructor
    - X Owners (passed in as array of addresses)
    - Y/X requiredSignatures (passed in as uint)
    (setup above in construction of contract)
    
    - deposit function (to take funds from anyone)
        Assume that all funds are kept together in one lump (ie. it won't record who contributes what funds!?)
        
    - createTransferRequest(toAddress, amount, reason?) onlyOwners
        How are other owners notified of transfer requests - events? / transfer Request log? both!
    - cancelTransferRequest : creator can cancel/delete

    -   numberPendingTransferRequests : Returns number of open requests
    -   getPendingTransferRequest(index) : Returns details of specic transfer requests
    
    - accceptTransferRequest(index) onlyOwners : Adds an approval vote to pending request, and triggers transfer if approval vote threshold reached
    - declineTransferRequest(index) onlyOwners : Adds a not approved vote to pending request, and rejects request if approval vote threshold can no longer be reached
    
    
    - getWalletBalance() - usefulfunction 
    
    Will need state variables for:
    - owners : array of owner addresses  or a mapping of address to bool true if owner
    - Struct type that holds requested transaction details - requestor, recipient, amount, possibly approversToDate (addresses[] or uint)??
    - pendingApprovalRequests: array of  structs (requested transactions) - with array index being used as requestId
    - openRequestsByOwner : mapping owner's address -> array of transfer request ids (uint[]) 
    
    - sentTransactions ? (possible nice to have, to keep a record of who approved sent transactions)
    - rejectedTransactions ? (possible nice to have, similar to above - keep a record of who rejected proposed Txs)    
    
 