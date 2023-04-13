require("dotenv").config();
const ethers = require("ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-deploy");
require("hardhat-contract-sizer");
require("hardhat-deploy-ethers");
require("@openzeppelin/hardhat-upgrades");

const { fund } = require("./tasks/fund");
const { task } = require("hardhat/config");

const mnemonic =
  "replace hover unaware super where filter stone fine garlic address matrix basic";

let privateKeys = [];

// creates the list of private keys from the mnemonic
// remove this if you will use a local network and you need the private keys
let derivePath = "m/44'/60'/0'/0/";
for (let i = 0; i <= 10; i++) {
  const wallet = new ethers.Wallet.fromMnemonic(mnemonic, `${derivePath}${i}`);
  privateKeys.push(wallet.privateKey);
}

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("fund", "Fund accounts on fork")
  .addOptionalParam("amount", "Stable coin amount to fund each account with")
  .addOptionalParam("fundnetwork", "forked Network")
  .addOptionalParam("localaccounts", " number of first local accounts to fund")
  .setAction(fund);

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: true,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: 1337,
      initialBaseFeePerGas: 0,
    },
    l1: {
      url: "http://0.0.0.0:8545/",
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
    },
    athens: {
      url: `https://api.athens2.zetachain.com/evm`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 7001,
    },
    l2: {
      url: "http://0.0.0.0:8565/",
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
    },
    goerli: {
      url: `https://rpc.ankr.com/eth_goerli`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 97,
    },
    mainnet: {
      url: `${process.env.MAINNET_PROVIDER_URL}`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 1,
    },
    skale: {
      url: `${process.env.SKALE_PROVIDER_URL}`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 0xafcee83030b95,
    },
    polygonMumbai: {
      url: `${process.env.MUMBAI_PROVIDER_URL}`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 80001,
    },
    polygon: {
      url: `${process.env.POLYGON_PROVIDER_URL}`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 137,
    },
    bscTestnet: {
      //url: `${process.env.BSCTEST_PROVIDER_URL}`,
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 97,
    },
    bsc: {
      url: `${process.env.BSC_PROVIDER_URL}`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || privateKeys[2],
        process.env.GOVERNOR_PRIVATE_KEY || privateKeys[1],
      ],
      chainId: 56,
    },
  },
  namedAccounts: {
    deployerAddr: {
      default: 0,
      localhost: 0,
      l1: 0,
    },
    governorAddr: {
      default: 1,
      localhost: 1,
      l1: 1,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGONSCAN_API_KEY,
      bscTestnet: process.env.BSCSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
    },
  },
};
