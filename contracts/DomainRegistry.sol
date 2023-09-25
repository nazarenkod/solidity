// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract DomainRegistry {
    uint256 constant REQUIRED_DEPOSIT = 1 ether; 
    
    

    struct Domain {
        address controller; 
        string tld; 
        uint256 createdTimestamp; 
        uint256 deposit; 
        bool isRegistered; 
        
    }


    // Мапа для зберігання доменів, де ключ - це назва домену верхнього рівня
    mapping(string => Domain) public domains;

    // Подія, яка виникає при створенні нового домену
    event DomainCreated(address indexed controller, string indexed tld, uint256 createdTimestamp, uint256 deposit);

    // Модифікатор перевірки застави
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

    // Додаємо новий домен до мапи
    domains[_tld] = Domain({
        controller: msg.sender,
        tld: _tld,
        createdTimestamp: block.timestamp,
        deposit: msg.value,
        isRegistered: true
    });


    emit DomainCreated(msg.sender, _tld, block.timestamp, msg.value);
}


    // Функція для звільнення домену та повернення застави ETH
    function releaseDomain(string memory _tld) public {
        Domain storage domain = domains[_tld];
        require(domain.isRegistered, "Domain isnt registered");
        require(msg.sender == domain.controller, "Error permission");
        
        uint256 depositAmount = domain.deposit;
        domain.isRegistered = false;
        domain.deposit = 0;
        
        // Повертаємо заставу ETH контролеру
        payable(msg.sender).transfer(depositAmount);
    }

    // Функція для отримання інформації про домен
    function getDomain(string memory _tld) public view returns (address, string memory, uint256, uint256, bool) {
        Domain memory domain = domains[_tld];
        return (domain.controller, domain.tld, domain.createdTimestamp, domain.deposit, domain.isRegistered);
    }
}
