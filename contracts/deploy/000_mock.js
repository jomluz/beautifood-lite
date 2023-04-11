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

const deployMockChainlinkPriceFeed = async () => {};

const main = async () => {
  await deployWithConfirmation("Beautifood");
};

main.id = "000_core";
main.skip = () => false;
module.exports = main;
