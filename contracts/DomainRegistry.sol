// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract DomainRegistry {
    uint256 constant REQUIRED_DEPOSIT = 1 ether;

    struct Domain {
        uint256 deposit;
        bool isRegistered;
    }

    mapping(string => Domain) public domains;

    event DomainCreated(string tld, uint256 deposit);
    event DomainReleased(string tld);

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
            deposit: msg.value,
            isRegistered: true
        });

        emit DomainCreated(_tld, msg.value);
    }

    function releaseDomain(string memory _tld) public {
        Domain storage domain = domains[_tld];
        require(domain.isRegistered, "Domain isn't registered");
        require(msg.sender == tx.origin, "Contracts cannot release domains");
    
        uint256 depositAmount = domain.deposit;
        domain.isRegistered = false;
        domain.deposit = 0;
    
        payable(msg.sender).transfer(depositAmount);

        emit DomainReleased(_tld);
    }
}
