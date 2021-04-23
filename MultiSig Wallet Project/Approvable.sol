pragma solidity 0.7.5;

contract Approvable {
    
    address[] internal _approvers;
    mapping (address => bool) internal _approvership;
    
    modifier onlyAnApprover(address candidate) {
         require(_approvership[candidate], "Not an approver!");
         _;
    }
    
    constructor(address[] memory approvers, uint minTxApprovals) {
        require(minTxApprovals < approvers.length, "Minimum approvers >= owners!");
        
        for (uint i=0; i < approvers.length; i++) {
            require(approvers[i] != address(0), "Approver has 0 address!");
            require(!_approvership[approvers[i]], "Duplicate approver address!");
            _approvers.push(approvers[i]);
            _approvership[approvers[i]] = true;
        }
        assert(_approvers.length == approvers.length);
    }

    function getApprovers() external view returns (address[] memory approvers){
        return _approvers;
    }
    
}