// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DomainUtils.sol";

contract DomainRegistry {
    using DomainUtils for string;

    uint256 constant REQUIRED_DEPOSIT = 1 ether;

    struct Domain {
        uint256 deposit;
        bool isRegistered;
        address owner;
    }

    mapping(string => Domain) public domains;

    event DomainCreated(string indexed domainName, uint256 deposit, address indexed owner);
    event DomainReleased(string indexed domainName);

    modifier hasRequiredDeposit() {
        require(msg.value == REQUIRED_DEPOSIT, "Wrong eth amount");
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

    modifier isValidDomain(string memory _domainName) {
        _domainName = _domainName.stripProtocol();
        require(bytes(_domainName).length > 0, "Domain is empty");
        bytes memory domainBytes = bytes(_domainName);
        require(domainBytes[domainBytes.length - 1] != bytes1('.'), "Domain ends with a dot");
        _;
    }

    modifier domainOwnedBySender(string memory domainName) {
        domainName = domainName.stripProtocol();
        require(domains[domainName].owner == msg.sender, "Not the domain owner");
        _;
    }

modifier parentDomainExists(string memory domainName) {
    if (isTopLevelDomain(domainName)) {
        _;
        return;
    }
    
    string memory parentDomain = domainName.extractParentDomain();
    if (bytes(parentDomain).length > 1) {  
        require(domains[parentDomain].isRegistered, "Parent domain doesn't exist");
    }
    _;
}

function isTopLevelDomain(string memory domainName) internal pure returns (bool) {
    bytes memory domainBytes = bytes(domainName);
    uint dotCount = 0;
    for (uint i = 0; i < domainBytes.length; i++) {
        if (domainBytes[i] == bytes1('.')) {
            dotCount++;
        }
    }
    return dotCount == 0;  
}

function registerDomain(string memory domainName) 
    public 
    hasRequiredDeposit() 
    domainExistence(domainName, false) 
    isValidDomain(domainName)
    parentDomainExists(domainName)
    payable 
{
    domainName = domainName.stripProtocol();
    require(bytes(domainName).length > 0, "Domain cannot be empty");

    domains[domainName] = Domain({
        deposit: msg.value,
        isRegistered: true,
        owner: msg.sender
    });

    emit DomainCreated(domainName, msg.value, msg.sender);
}

    function releaseDomain(string memory domainName) 
        public 
        domainExistence(domainName, true) 
        domainOwnedBySender(domainName) 
    {
        domainName = domainName.stripProtocol();
        
        Domain storage domain = domains[domainName];
        uint256 depositAmount = domain.deposit;

        domain.isRegistered = false;
        domain.deposit = 0;
        domain.owner = address(0);

        payable(msg.sender).transfer(depositAmount);

        emit DomainReleased(domainName);
    }

}
