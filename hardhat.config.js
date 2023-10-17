require('@openzeppelin/hardhat-upgrades');
require("@nomicfoundation/hardhat-toolbox");



const MNEMONIC = "test test test test test test test test test test test junk"
const INFURA_API_KEY = "";




/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",

  networks: {
    hardhat: {
      accounts: {
        mnemonic: MNEMONIC,
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
      },
    },
    localhost: {
      url: "http://127.0.0.1:7545",
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: {
        mnemonic: MNEMONIC,
      }
    }
  }
};