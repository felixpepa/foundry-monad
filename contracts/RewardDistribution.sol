pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./CuraToken.sol";
using ECDSA for bytes32;

contract RewardDistribution {
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
        address signer = recoverSigner(messageHash, signature);
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
        return ECDSA.recover(ECDSA.toEthSignedMessageHash(message), sig);
    }
} 