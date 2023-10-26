const { ethers, upgrades } = require("hardhat");

async function main() {
    const existingContractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";  

    const ContractV2 = await ethers.getContractFactory("DomainRegistryImplementationV2");

    await upgrades.upgradeProxy(existingContractAddress, ContractV2);
    
    console.log("DomainRegistryImplementationV1 upgraded to V2 at:", existingContractAddress);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
