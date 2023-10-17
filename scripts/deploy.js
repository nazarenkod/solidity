const { ethers, upgrades } = require("hardhat");

async function main() {
    try {
        const Contract = await ethers.getContractFactory("DomainRegistryImplementationV1");
        const contract = await upgrades.deployProxy(Contract);

        console.log("DomainRegistryImplementationV1 deployed to:",await contract.getAddress());
    } catch (error) {
        console.error("Error deploying contract:", error);
    }
    
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
