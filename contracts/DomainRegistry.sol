// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DomainUtils.sol";

contract DomainRegistry {
    using DomainUtils for string;

    address public owner;
    uint256 public registrationFee = 1 ether;
    uint256 public refundPercentage = 10;

    struct Domain {
        bool isRegistered;
        address owner;
    }

    mapping(string => Domain) public domains;

    event DomainCreated(string indexed domainName, address indexed owner);
    event DomainReleased(string indexed domainName);

    constructor() {
        owner = msg.sender;
    }

    modifier hasRequiredFee() {
        require(msg.value == registrationFee, "Wrong eth amount");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
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

    function setRegistrationFee(uint256 _fee) external onlyOwner {
        registrationFee = _fee;
    }

    function registerDomain(string memory domainName) 
        public 
        hasRequiredFee() 
        domainExistence(domainName, false) 
        isValidDomain(domainName)
        parentDomainExists(domainName)
        payable 
    {
        domainName = domainName.stripProtocol();
        require(bytes(domainName).length > 0, "Domain cannot be empty");

        domains[domainName] = Domain({
            isRegistered: true,
            owner: msg.sender
        });

        emit DomainCreated(domainName, msg.sender);
    }
    //Money back for release domain with refundPercentage
    function releaseDomain(string memory domainName) 
        public 
        domainExistence(domainName, true) 
        domainOwnedBySender(domainName) 
    {
        domainName = domainName.stripProtocol();
        
        Domain storage domain = domains[domainName];
        domain.isRegistered = false;
        domain.owner = address(0);

        uint256 refundAmount = (registrationFee * refundPercentage) / 100; 
        payable(msg.sender).transfer(refundAmount);

        emit DomainReleased(domainName);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
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
}







