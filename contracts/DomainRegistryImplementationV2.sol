// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./DomainUtils.sol";

/**
 * @title DomainRegistryImplementationV2
 * @dev This contract allows users to register and manage domains.
 */
contract DomainRegistryImplementationV2 is Initializable, OwnableUpgradeable {
    using Address for address payable;
    using DomainUtils for string;

    uint256 public domainPrice;

    struct Domain {
        bool isRegistered;
        address owner;
    }

    mapping(string => Domain) public domains;
    mapping(string => uint256) public rewards;
    mapping(string => bool) public rewardsClaimed;
    mapping(string => uint256) public domainRewards;

    event DomainRegistered(string indexed domainName, address indexed owner);
    event DomainReleased(string indexed domainName);
    event RewardSet(string indexed domainName, uint256 rewardAmount);
    event RewardClaimed(string indexed childDomain, uint256 rewardAmount);

    /**
     * @dev Initializes the contract.
     */
    function initialize() public initializer {
        __Ownable_init();
        domainPrice = 1 ether;
    }

    modifier isValidDomain(string memory _domainName) {
        _domainName = _domainName.stripProtocol();
        require(bytes(_domainName).length > 0, "Domain is empty");
        bytes memory domainBytes = bytes(_domainName);
        require(
            domainBytes[domainBytes.length - 1] != bytes1("."),
            "Domain ends with a dot"
        );
        _;
    }

    modifier domainOwnedBySender(string memory domainName) {
        domainName = domainName.stripProtocol();
        require(
            domains[domainName].owner == msg.sender,
            "Not the domain owner"
        );
        _;
    }

    modifier domainExistence(string memory domainName, bool shouldExist) {
        bool exists = domains[domainName.stripProtocol()].owner != address(0);
        if (shouldExist) {
            require(exists, "Domain doesn't exist");
        } else {
            require(!exists, "Domain exists");
        }
        _;
    }

    /**
     * @dev Sets the price for registering a domain.
     * @param _price The new domain registration price.
     */
    function setDomainPrice(uint256 _price) external onlyOwner {
        domainPrice = _price;
    }

    /**
     * @dev Sets a reward for child domains.
     * @param domainName The parent domain for which to set the reward.
     * @param rewardAmount The reward amount to set.
     */
    function setRewardForChildDomains(
        string memory domainName,
        uint256 rewardAmount
    )
        external
        payable
        domainExistence(domainName, true)
        domainOwnedBySender(domainName)
    {
        require(msg.value == rewardAmount, "Incorrect amount sent");
        rewards[domainName] = rewardAmount;
        emit RewardSet(domainName, rewardAmount);
    }

    /**
     * @dev Sets the reward for a specific domain.
     * @param domainName The domain for which to set the reward.
     * @param reward The reward amount to set.
     */
    function setDomainReward(
        string memory domainName,
        uint256 reward
    ) external onlyOwner {
        require(domains[domainName].isRegistered, "Domain doesn't exist");
        domainRewards[domainName] = reward;
    }

    /**
     * @dev Claims a reward for a child domain.
     * @param childDomain The child domain for which to claim the reward.
     */
    function claimReward(
        string memory childDomain
    )
        external
        domainExistence(childDomain, true)
        domainOwnedBySender(childDomain)
    {
        require(!rewardsClaimed[childDomain], "Reward already claimed");
        string memory parentDomain = DomainUtils.extractParentDomain(
            childDomain
        );
        uint256 rewardAmount = rewards[parentDomain]; // Retrieve the reward before transferring

        require(rewardAmount > 0, "No reward set by parent domain");
        rewards[parentDomain] = 0; // Zero out the reward before transferring to prevent reentrancy

        address payable recipient = payable(domains[childDomain].owner);
        bool transferSuccess = false;

        // Attempt the transfer
        (transferSuccess, ) = recipient.call{value: rewardAmount}("");

        require(transferSuccess, "Transfer failed");

        rewardsClaimed[childDomain] = true;

        emit RewardClaimed(childDomain, rewardAmount);
    }

    /**
     * @dev Registers a domain.
     * @param domainName The domain to register.
     */
    function registerDomain(
        string memory domainName
    )
        public
        payable
        isValidDomain(domainName)
        domainExistence(domainName, false)
    {
        require(msg.value == domainPrice, "Incorrect amount sent");

        domainName = domainName.stripProtocol();

        string memory parentDomain = DomainUtils.extractParentDomain(
            domainName
        );
        if (bytes(parentDomain).length > 0) {
            require(
                domains[parentDomain].isRegistered,
                "Parent domain doesn't exist"
            );
            domainRewards[domainName] = domainRewards[parentDomain];
        }

        domains[domainName] = Domain({isRegistered: true, owner: msg.sender});

        emit DomainRegistered(domainName, msg.sender);
    }

    /**
     * @dev Releases a domain.
     * @param domainName The domain to release.
     */
    function releaseDomain(
        string memory domainName
    ) public domainExistence(domainName, true) domainOwnedBySender(domainName) {
        domainName = domainName.stripProtocol();
        delete domains[domainName];
        emit DomainReleased(domainName);
    }

    /**
     * @dev Withdraws funds from the contract.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Withdrawal amount must be greater than 0");
        payable(owner()).transfer(balance);
    }
}
