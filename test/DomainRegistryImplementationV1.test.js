const { expect } = require("chai");

describe("DomainRegistry", function () {
  let domainRegistry;

  beforeEach(async function () {
    const hre = require("hardhat");
    const DomainRegistry = await hre.ethers.getContractFactory("DomainRegistryImplementationV1");
    domainRegistry = await DomainRegistry.deploy();
    await domainRegistry.initialize(); 
});

  it("Should register a new .com domain", async function () {
    const _topLevelDomain = "com";
    await domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
    });
    const domainInfo = await domainRegistry.domains(_topLevelDomain);
    expect(domainInfo.isRegistered).to.be.true;
  });

  it("Should release a registered .gov domain", async function () {
    const _topLevelDomain = "gov";
    await domainRegistry.registerDomain(_topLevelDomain, {
      value: hre.ethers.parseEther("1.0"),
    });
    await domainRegistry.releaseDomain(_topLevelDomain);
    const domainInfo = await domainRegistry.domains(_topLevelDomain);
    expect(domainInfo.isRegistered).to.be.false;
  });

  it("Should fail to register a duplicate .com domain", async function () {
    const _topLevelDomain = "com"; 
    await domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
    });
    await expect(
      domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Domain exists");
  });

  it("Should fail to register an empty domain", async function () {
    const _topLevelDomain = "";
    await expect(
      domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Domain is empty");
  });

  it("Should fail to register a domain with an insufficient deposit", async function () {
    const _topLevelDomain = "com";
    await expect(
      domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("0.5"),
      })
    ).to.be.revertedWith("Incorrect amount sent");
  });

  it("Should fail to release a non-existing .org domain", async function () {
    const _topLevelDomain = "org";
    await expect(
      domainRegistry.releaseDomain(_topLevelDomain)
    ).to.be.revertedWith("Domain doesn't exist");
  });

  it("Should successfully register a multi-level domain", async function () {
    const topLevelDomain = "com";
    const secondLevelDomain = "example.com";
    await domainRegistry.registerDomain(topLevelDomain, {
      value: hre.ethers.parseEther("1.0"),
    });
    await domainRegistry.registerDomain(secondLevelDomain, {
      value: hre.ethers.parseEther("1.0"),
    });
    const domainInfo = await domainRegistry.domains(secondLevelDomain);
    expect(domainInfo.isRegistered).to.be.true;
  });

  it("Should fail to register a multi-level domain if parent is not registered", async function () {
    const multiLevelDomain = "sub.example.com";
    await expect(
      domainRegistry.registerDomain(multiLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Parent domain doesn't exist");
  });

  it("Should successfully register a domain with multiple levels", async function () {
    const topLevel = "org";
    const secondLevel = "example.org";
    const thirdLevel = "sub.example.org";
  
    await domainRegistry.registerDomain(topLevel, {
      value: hre.ethers.parseEther("1.0"),
    });
    
    await domainRegistry.registerDomain(secondLevel, {
      value: hre.ethers.parseEther("1.0"),
    });
    
    await domainRegistry.registerDomain(thirdLevel, {
      value: hre.ethers.parseEther("1.0"),
    });

    const domainInfoThirdLevel = await domainRegistry.domains(thirdLevel);
    expect(domainInfoThirdLevel.isRegistered).to.be.true;
  });

  it("Should successfully register a domain with 'https://' protocol", async function () {
    const parentDomain = "com";
    await domainRegistry.registerDomain(parentDomain, {
        value: hre.ethers.parseEther("1.0"),
    });

    const domainWithProtocol = "https://example.com";
    await domainRegistry.registerDomain(domainWithProtocol, {
        value: hre.ethers.parseEther("1.0"),
    });

    const domainInfo = await domainRegistry.domains("example.com");
    expect(domainInfo.isRegistered).to.be.true;
  });

});
