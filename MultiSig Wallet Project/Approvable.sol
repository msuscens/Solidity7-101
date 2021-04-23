pragma solidity 0.7.5;

contract Approvable {
    
    address[] internal _approvers;
    mapping (address => bool) internal _approvership;
    uint internal _minApprovals;

    modifier onlyAnApprover(address candidate) {
         require(_approvership[candidate], "Not an approver!");
         _;
    }
    
    constructor(address[] memory approvers, uint minApprovals) {
        require(minApprovals <= approvers.length, "Minimum approvals > approvers!");
        
        for (uint i=0; i < approvers.length; i++) {
            require(approvers[i] != address(0), "Approver has 0 address!");
            require(!_approvership[approvers[i]], "Duplicate approver address!");
            _approvers.push(approvers[i]);
            _approvership[approvers[i]] = true;
        }
        _minApprovals = minApprovals;

        assert(_approvers.length == approvers.length);
    }

    function getApprovers() external view returns (address[] memory approvers){
        return _approvers;
    }
    
    function getMinApprovals() external view returns (uint){
        return _minApprovals;
    }
}