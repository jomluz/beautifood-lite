require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const {
  getTokenAddresses,
  isLocalHost,
  isFork,
  isL1,
} = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const deployMockChainlinkPriceFeed = async () => {};

const main = async () => {
  await deployWithConfirmation("Beautifood");
  await deployWithConfirmation("USDC", ["US Dollar", "USDC"], "MockERC20");
};

main.id = "000_core";
main.skip = () => !isL1;
module.exports = main;
