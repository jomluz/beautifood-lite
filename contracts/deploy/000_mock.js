require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const { getTokenAddresses, isLocalHost, isFork } = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const deployMockChainlinkPriceFeed = async () => {
  const {deployerAddr} = await getNamedAccounts();
  console.log(deployerAddr);
  console.log((await ethers.provider.getNetwork()))
  const balance = await ethers.provider.getBalance("0x4C91bd65c12953be3096e6b66ebc74e423739fa1");
  console.log(balance.toString());
  await deployWithConfirmation("MockChainlinkOracleFeed", [
    parseUnits("1", 8).toString(),
    18,
  ]);
};

const main = async () => {
  await deployMockChainlinkPriceFeed();
};

main.id = "001_core";
main.skip = () => false;
module.exports = main;
