const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");


describe("DomainRegistryUpgrade", function () {
  let domainRegistryV1;
  let domainRegistryV2;

  beforeEach(async () => {

  });


  it("should verify data migration from V1 to V2", async function () {

    const DomainRegistryV1 = await ethers.getContractFactory("DomainRegistryImplementationV1");
    const domainRegistryV1 = await upgrades.deployProxy(DomainRegistryV1);
    console.log("DomainRegistryImplementationV1 deployed to:",await domainRegistryV1.getAddress());
    let adress = domainRegistryV1.getAddress()
 
    const _topLevelDomain = "com";
    await domainRegistryV1.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
    });
    const domainInfoV1 = await domainRegistryV1.domains(_topLevelDomain);
    expect(domainInfoV1.isRegistered).to.be.true;
    

    const DomainRegistryV2 = await ethers.getContractFactory("DomainRegistryImplementationV2");
    domainRegistryV2 = await upgrades.upgradeProxy("0x4631BCAbD6dF18D94796344963cB60d44a4136b6", DomainRegistryV2);
    console.log("DomainRegistryImplementationV2 deployed to:",await domainRegistryV2.getAddress());
    const domainInfoV2 = await domainRegistryV2.domains(_topLevelDomain);
    expect(domainInfoV2.isRegistered).to.be.true;


  });
});