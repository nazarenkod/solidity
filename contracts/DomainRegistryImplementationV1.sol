// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./DomainUtils.sol";

contract DomainRegistryImplementationV1 is Initializable, OwnableUpgradeable {
    using Address for address payable;
    using DomainUtils for string;

    uint256 public domainPrice;

    struct Domain {
        bool isRegistered;
        address owner;
    }

    mapping(string => Domain) public domains;

    event DomainRegistered(string indexed domainName, address indexed owner);
    event DomainReleased(string indexed domainName);

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

    function setDomainPrice(uint256 _price) external onlyOwner {
        domainPrice = _price;
    }

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
        }

        domains[domainName] = Domain({isRegistered: true, owner: msg.sender});

        emit DomainRegistered(domainName, msg.sender);
    }

    function releaseDomain(
        string memory domainName
    ) public domainExistence(domainName, true) domainOwnedBySender(domainName) {
        domainName = domainName.stripProtocol();
        delete domains[domainName];
        emit DomainReleased(domainName);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).sendValue(balance);
    }
}
