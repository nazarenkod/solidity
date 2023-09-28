const { expect } = require("chai");

describe("DomainRegistry", function () {
  let domainRegistry;
  let domainName;
  let owner; 

  before(async function () {    
    const hre = require("hardhat");
    const DomainRegistry = await hre.ethers.getContractFactory("DomainRegistry");
    domainRegistry = await DomainRegistry.deploy();
    [owner] = await hre.ethers.getSigners();
    domainName = "com"; 
    const amountInEther = "1.0";
    const amountInWei = hre.ethers.parseEther(amountInEther);
    const registerTransaction = await domainRegistry.connect(owner).registerDomain(domainName, {
      value: amountInWei,
    });

    await registerTransaction.wait();
  });

  it("Should register a new domain", async function () {    
    const domainInfo = await domainRegistry.getDomain(domainName);
    expect(domainInfo[3]).to.be.true;
  });

  it("Should release a registered domain", async function () {
    await domainRegistry.connect(owner).releaseDomain(domainName);
    const domainInfo = await domainRegistry.getDomain(domainName);
    expect(domainInfo[3]).to.be.false;
  });

  it("Should fail to register a duplicate domain", async function () {
    const uniqueTld = "com";
    await domainRegistry.connect(owner).registerDomain(uniqueTld, {
      value: hre.ethers.parseEther("1.0"),
    });
    await expect(
      domainRegistry.connect(owner).registerDomain(uniqueTld, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Domain exists");
  });

  it("Should fail to register an invalid domain", async function () {
    await expect(
      domainRegistry.connect(owner).registerDomain("business.com", {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Wrong domain level");
  });

  it("Should fail to register a domain with insufficient deposit", async function () {
    await expect(
      domainRegistry.connect(owner).registerDomain("org", {
        value: hre.ethers.parseEther("0.5"),
      })
    ).to.be.revertedWith("Wrong eth amount");
  });

  it("Should fail to release a non-existing domain", async function () {
    await expect(
      domainRegistry.connect(owner).releaseDomain("nonexisting")
    ).to.be.revertedWith("Domain isnt registered");
  });

  it("Should get domain information", async function () {
    const domainInfo = await domainRegistry.getDomain(domainName);
    expect(domainInfo[0]).to.equal(owner.address);
  });
});
