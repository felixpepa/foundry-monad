pragma solidity ^0.8.13;

contract AdminManagement {
    address public superAdmin;
    mapping(address => bool) public admins;

    constructor() {
        superAdmin = msg.sender;
    }

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "Unauthorized");
        _;
    }

    function addAdmin(address _admin) external onlySuperAdmin {
        require(!admins[_admin], "Admin already exists");
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlySuperAdmin {
        require(admins[_admin], "Admin not found");
        admins[_admin] = false;
    }
} 