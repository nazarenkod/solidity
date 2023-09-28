// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract DomainRegistry {
    uint256 constant REQUIRED_DEPOSIT = 1 ether;

    struct Domain {
        address controller;
        uint256 createdTimestamp;
        uint256 deposit;
        bool isRegistered;
    }

    mapping(string => Domain) public domains;

    event DomainCreated(address indexed controller, bytes32 indexed tldHash, string tld, uint256 createdTimestamp, uint256 deposit);

    modifier hasRequiredDeposit(uint256 _requiredDeposit) {
        require(msg.value >= _requiredDeposit, "Wrong eth amount");
        _;
    }

    modifier domainDoesNotExist(string memory _tld) {
        require(!domains[_tld].isRegistered, "Domain exists");
        _;
    }

    modifier isValidDomain(string memory _tld) {
        require(keccak256(bytes(_tld)) == keccak256(bytes("com")) || keccak256(bytes(_tld)) == keccak256(bytes("gov")), "Wrong domain level");
        _;
    }

    function registerDomain(string memory _tld) public hasRequiredDeposit(REQUIRED_DEPOSIT) domainDoesNotExist(_tld) isValidDomain(_tld) payable {
        domains[_tld] = Domain({
            controller: msg.sender,
            createdTimestamp: block.timestamp,
            deposit: msg.value,
            isRegistered: true
        });

        emit DomainCreated(msg.sender, keccak256(bytes(_tld)), _tld, block.timestamp, msg.value);
    }

    function releaseDomain(string memory _tld) public {
        Domain storage domain = domains[_tld];
        require(domain.isRegistered, "Domain isnt registered");
        require(msg.sender == domain.controller, "Error permission");
        
        uint256 depositAmount = domain.deposit;
        domain.isRegistered = false;
        domain.deposit = 0;
        
        payable(msg.sender).transfer(depositAmount);
    }

    function getDomain(string memory _tld) public view returns (address, uint256, uint256, bool) {
        Domain memory domain = domains[_tld];
        return (domain.controller, domain.createdTimestamp, domain.deposit, domain.isRegistered);
    }
}
