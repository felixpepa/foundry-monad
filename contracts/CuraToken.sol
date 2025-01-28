pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./AdminManagement.sol";

contract CuraToken is ERC20 {
    AdminManagement public adminManagement;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public blacklist;

    constructor(address _adminManagement) ERC20("Cura Token", "CT") {
        adminManagement = AdminManagement(_adminManagement);
    }

    modifier onlyAdmin() {
        require(
            adminManagement.admins(msg.sender) || msg.sender == adminManagement.superAdmin(),
            "Unauthorized"
        );
        _;
    }

    function mint(address to, uint256 amount) external onlyAdmin {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function updateWhitelist(address account, bool status) external onlyAdmin {
        whitelist[account] = status;
    }

    function updateBlacklist(address account, bool status) external onlyAdmin {
        blacklist[account] = status;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(!blacklist[to], "Transfer to blacklisted account not allowed");
        if (from != address(0)) {
            require(whitelist[from], "Sender not in whitelist");
        }
        super._beforeTokenTransfer(from, to, amount);
    }
} 