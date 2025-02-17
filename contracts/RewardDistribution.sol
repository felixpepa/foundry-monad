pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "./CuraToken.sol";

contract RewardDistribution {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    
    CuraToken public token;
    AdminManagement public adminManagement;

    mapping(uint256 => bool) public processedRewardIds;

    constructor(address _token, address _adminManagement) {
        token = CuraToken(_token);
        adminManagement = AdminManagement(_adminManagement);
    }

    function distributeReward(
        uint256 rewardId,
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external {
        require(!processedRewardIds[rewardId], "Duplicate reward id");
        bytes32 messageHash = keccak256(abi.encodePacked(rewardId, recipient, amount));
        // Hash the message according to EIP-191
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        // Recover the signer
        address signer = ECDSA.recover(ethSignedMessageHash, signature);
        
        require(
            adminManagement.admins(signer) || signer == adminManagement.superAdmin(),
            "Unauthorized"
        );
        processedRewardIds[rewardId] = true;
        token.mint(recipient, amount);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        public
        pure
        returns (address)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(message);
        return ECDSA.recover(ethSignedMessageHash, sig);
    }
} 