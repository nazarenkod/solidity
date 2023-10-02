const { expect } = require("chai");

describe("DomainRegistry", function () {
  let domainRegistry;

  beforeEach(async function () {
    const hre = require("hardhat");
    const DomainRegistry = await hre.ethers.getContractFactory("DomainRegistry");
    domainRegistry = await DomainRegistry.deploy();
  });

  it("Should register a new .com domain", async function () {
    const _topLevelDomain = "com";
    await domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
    });
    const domainInfo = await domainRegistry.domains(_topLevelDomain);
    expect(domainInfo.isRegistered).to.be.true;
    expect(domainInfo.deposit).to.equal(hre.ethers.parseEther("1.0"));
  });

  it("Should release a registered .gov domain", async function () {
    const _topLevelDomain = "gov";
    await domainRegistry.registerDomain(_topLevelDomain, {
      value: hre.ethers.parseEther("1.0"),
    });
    await domainRegistry.releaseDomain(_topLevelDomain);
    const domainInfo = await domainRegistry.domains(_topLevelDomain);
    expect(domainInfo.isRegistered).to.be.false;
    expect(domainInfo.deposit).to.equal(0);
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

  it("Should fail to register a multilevel domain", async function () {
    const _topLevelDomain = ".business.com";
    await expect(
      domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Multilevel domains are not allowed");
  });

  it("Should fail to register a domain which finishes with a dot", async function () {
    const _topLevelDomain = "business.";
    await expect(
      domainRegistry.registerDomain(_topLevelDomain, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Multilevel domains are not allowed");
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
    ).to.be.revertedWith("Wrong eth amount");
  });

  it("Should fail to release a non-existing .org domain", async function () {
    const _topLevelDomain = "org";
    await expect(
      domainRegistry.releaseDomain(_topLevelDomain)
    ).to.be.revertedWith("Domain doesn't exist");
  });
});
