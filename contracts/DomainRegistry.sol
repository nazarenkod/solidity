pragma solidity 0.8.20;

contract DomainRegistry {
    uint256 constant REQUIRED_DEPOSIT = 1 ether;

    struct Domain {
        uint256 deposit;
        bool isRegistered;
        address owner;
    }

    mapping(string => Domain) public domains;

    event DomainCreated(string indexed topLevelDomain, uint256 deposit, address indexed owner);
    event DomainReleased(string indexed topLevelDomain);


    modifier hasRequiredDeposit() {
        require(msg.value == REQUIRED_DEPOSIT, "Wrong eth amount");
        _;
    }

    modifier domainDoesNotExist(string memory _topLevelDomain) {
        require(!domains[_topLevelDomain].isRegistered, "Domain exists");
        _;
    }

    modifier domainExists(string memory _topLevelDomain) {
        require(domains[_topLevelDomain].isRegistered, "Domain doesn't exist");
        _;
    }

    modifier domainOwnedBySender(string memory _topLevelDomain) {
        require(domains[_topLevelDomain].owner == msg.sender, "Not the domain owner");
        _;
    }

    modifier isTopLevelDomain(string memory _topLevelDomain) {
        require(bytes(_topLevelDomain).length > 0, "Domain is empty");
        for (uint i = 0; i < bytes(_topLevelDomain).length; i++) {
            require(bytes(_topLevelDomain)[i] != bytes(".")[0], "Multilevel domains are not allowed");
        }
        _;
    }

    function registerDomain(string memory _topLevelDomain) public hasRequiredDeposit() domainDoesNotExist(_topLevelDomain) isTopLevelDomain(_topLevelDomain) payable {
        domains[_topLevelDomain] = Domain({
            deposit: msg.value,
            isRegistered: true,
            owner: msg.sender
        });

        emit DomainCreated(_topLevelDomain, msg.value, msg.sender);
    }

    function releaseDomain(string memory _topLevelDomain) public domainExists(_topLevelDomain) domainOwnedBySender(_topLevelDomain) {
        Domain storage domain = domains[_topLevelDomain];
        uint256 depositAmount = domain.deposit;
        domain.isRegistered = false;
        domain.deposit = 0;
        domain.owner = address(0);
        payable(msg.sender).transfer(depositAmount);
        emit DomainReleased(_topLevelDomain);
    }
}
