const { expect } = require("chai");

describe("DomainRegistry", function () {
  let domainRegistry; // Объявляем переменную для контракта
  let tldToRegister; // Объявляем переменную для домена
  let owner; // Объявляем переменную для аккаунта владельца

  before(async function () {
    // Получаем доступ к Hardhat Runtime Environment (hre)
    const hre = require("hardhat");

    // Получаем фабрику контракта DomainRegistry
    const DomainRegistry = await hre.ethers.getContractFactory("DomainRegistry");

    // Деплоим контракт DomainRegistry и сохраняем его в переменной
    domainRegistry = await DomainRegistry.deploy();

    // Получаем аккаунты из Hardhat
    [owner] = await hre.ethers.getSigners();

    // Параметры для регистрации домена
    tldToRegister = "com"; // Убедитесь, что tldToRegister установлен в корректное значение
    const amountInEther = "1.0";
    const amountInWei = hre.ethers.parseEther(amountInEther);

    // Регистрируем домен
    const registerTransaction = await domainRegistry.connect(owner).registerDomain(tldToRegister, {
      value: amountInWei,
    });

    // Ждем окончания транзакции
    await registerTransaction.wait();
  });

  it("Should register a new domain", async function () {
    // Получаем информацию о зарегистрированном домене
    const domainInfo = await domainRegistry.getDomain(tldToRegister);

    // Проверяем, что домен зарегистрирован успешно
    expect(domainInfo[4]).to.be.true; // Используем индекс 4 для isRegistered
  });

  it("Should release a registered domain", async function () {
    // Освободите зарегистрированный домен
    await domainRegistry.connect(owner).releaseDomain(tldToRegister);

    // Проверьте, что домен больше не зарегистрирован
    const domainInfo = await domainRegistry.getDomain(tldToRegister);
    expect(domainInfo[4]).to.be.false; // Используем индекс 4 для isRegistered
  });

  it("Should fail to register a duplicate domain", async function () {
    const uniqueTld = "com";
  
    // Регистрируем этот домен
    await domainRegistry.connect(owner).registerDomain(uniqueTld, {
      value: hre.ethers.parseEther("1.0"),
    });
  
    // Попробуйте зарегистрировать домен с тем же именем, которое уже зарегистрировано
    await expect(
      domainRegistry.connect(owner).registerDomain(uniqueTld, {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Domain exists");
  });

  it("Should fail to register an invalid domain", async function () {
    // Попробуйте зарегистрировать домен с недопустимым доменным уровнем (например, "invalid"), и проверьте, что он вернул ошибку.
    await expect(
      domainRegistry.connect(owner).registerDomain("business.com", {
        value: hre.ethers.parseEther("1.0"),
      })
    ).to.be.revertedWith("Wrong domain level");
  });

  it("Should fail to register a domain with insufficient deposit", async function () {
    // Попробуйте зарегистрировать домен с суммой меньше, чем REQUIRED_DEPOSIT, и проверьте, что он вернул ошибку.
    await expect(
      domainRegistry.connect(owner).registerDomain("org", {
        value: hre.ethers.parseEther("0.5"),
      })
    ).to.be.revertedWith("Wrong eth amount");
  });

  it("Should fail to release a non-existing domain", async function () {
    // Попробуйте освободить домен, который не существует, и проверьте, что он вернул ошибку.
    await expect(
      domainRegistry.connect(owner).releaseDomain("nonexisting")
    ).to.be.revertedWith("Domain isnt registered");
  });

  it("Should get domain information", async function () {
    const domainInfo = await domainRegistry.getDomain(tldToRegister);
    expect(domainInfo[0]).to.equal(owner.address); // Проверка контроллера домена
    expect(domainInfo[1]).to.equal(tldToRegister); // Проверка доменного имени
  });
});

