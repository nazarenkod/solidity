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
    });
});