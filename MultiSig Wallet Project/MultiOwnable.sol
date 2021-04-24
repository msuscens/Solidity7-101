pragma solidity 0.7.5;

contract MultiOwnable {
    
    address[] internal _owners;
    mapping (address => bool) internal _ownership;

    modifier onlyAnOwner(address candidate) {
        require(_ownership[candidate], "Not an owner!");
        _;
    }
    
    constructor(address[] memory owners) {

        for (uint i=0; i < owners.length; i++) {
            require(owners[i] != address(0), "Owner with 0 address!");
            require(!_ownership[owners[i]], "Duplicate owner address!");
            _owners.push(owners[i]);
            _ownership[owners[i]] = true;
        }
        assert(_owners.length == owners.length);
    }
    
    function getOwners() external view returns (address[] memory owners){
        return _owners;
    }
      
}