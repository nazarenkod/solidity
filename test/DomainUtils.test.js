const { expect } = require("chai");

describe("DomainUtils", function () {
    let domainUtilsWrapper;

    beforeEach(async function () {
        const hre = require("hardhat");
        const DomainRegistry = await hre.ethers.getContractFactory("DomainUtilsWrapper");
        domainUtilsWrapper = await DomainRegistry.deploy();
    });

    it("Should strip protocol correctly", async function () {
        expect(await domainUtilsWrapper.stripProtocol("https://google.com")).to.equal("google.com");
        expect(await domainUtilsWrapper.stripProtocol("http://google.com")).to.equal("google.com");
    });

    it("Should extract parent domain correctly", async function () {
        expect(await domainUtilsWrapper.extractParentDomain("sub.google.com")).to.equal("google.com");
        expect(await domainUtilsWrapper.extractParentDomain("google.com")).to.equal("com");
    });

    it("Should detect prefixes correctly", async function () {
      expect(await domainUtilsWrapper.hasPrefix("https://google.com", "https://")).to.be.true;
      expect(await domainUtilsWrapper.hasPrefix("http://google.com", "https://")).to.be.false;
      expect(await domainUtilsWrapper.hasPrefix("google.com", "https://")).to.be.false;
  });

  it("Should extract substrings correctly", async function () {
      expect(await domainUtilsWrapper.substring("google.com", 0, 6)).to.equal("google");
      expect(await domainUtilsWrapper.substring("google.com", 7, 10)).to.equal("com");
  });

  it("Should find the index of a character correctly", async function () {
      expect(await domainUtilsWrapper.indexOf("google.com", "0x2e", 0));
  });

  it("Should domain level", async function () {
    expect(await domainUtilsWrapper.getDomainLevel("google.com")).to.equal(2); 
    expect(await domainUtilsWrapper.getDomainLevel("com")).to.equal(1); 
    expect(await domainUtilsWrapper.getDomainLevel("ex.google.com")).to.equal(3); 
  });

});