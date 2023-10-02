const { expect } = require("chai");

describe("DomainRegistry", function () {
  let domainRegistry;
  let owner;

  beforeEach(async function () {
    const hre = require("hardhat");
    const DomainRegistry = await hre.ethers.getContractFactory("DomainRegistry");
    domainRegistry = await DomainRegistry.deploy();
    [owner] = await hre.ethers.getSigners();
  });

  it("Should register a new .com domain", async function () {
    const domainForThisTest = "com";
    const tx = await domainRegistry.connect(owner).registerDomain(domainForThisTest, {
        value: hre.ethers.parseEther("1.0"),
    });
    await tx.wait();
    const domainInfo = await domainRegistry.domains(domainForThisTest);
    expect(domainInfo.isRegistered).to.be.true;
    expect(domainInfo.deposit).to.equal(hre.ethers.parseEther("1.0"));
  });

  it("Should release a registered .gov domain", async function () {
    const domainForThisTest = "gov";
    await domainRegistry.connect(owner).registerDomain(domainForThisTest, {
      value: hre.ethers.parseEther("1.0"),
    });
    await domainRegistry.connect(owner).releaseDomain(domainForThisTest);
    const domainInfo = await domainRegistry.domains(domainForThisTest);
    expect(domainInfo.isRegistered).to.be.false;
    expect(domainInfo.deposit).to.equal(0);
  });

  it("Should fail to register a duplicate .com domain", async function () {
    const domainForThisTest = "com"; 
    await domainRegistry.connect(owner).registerDomain(domainForThisTest, {
        value: hre.ethers.parseEther("1.0"),
    });
    await expect(
      domainRegistry.connect(owner).registerDomain(domainForThisTest, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Domain exists");
  });

  it("Should fail to register a multilevel domain", async function () {
    await expect(
      domainRegistry.connect(owner).registerDomain(".business.com", {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Multilevel domains are not allowed");
  });

  it("Should fail to register a domain wich finish with dot", async function () {
    await expect(
      domainRegistry.connect(owner).registerDomain("business.", {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Multilevel domains are not allowed");
  });

  it("Should fail to register empty domain", async function () {
    await expect(
      domainRegistry.connect(owner).registerDomain("", {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Domain is empty");
  });

  it("Should fail to register a domain with insufficient deposit", async function () {
    const insufficientTld = "com";
    await expect(
      domainRegistry.connect(owner).registerDomain(insufficientTld, {
        value: hre.ethers.parseEther("0.5"),
      })
    ).to.be.revertedWith("Wrong eth amount");
  });

  it("Should fail to release a non-existing .org domain", async function () {
    const nonExistingTld = "org";
    await expect(
      domainRegistry.connect(owner).releaseDomain(nonExistingTld)
    ).to.be.revertedWith("Domain isn't registered");
  });
});
