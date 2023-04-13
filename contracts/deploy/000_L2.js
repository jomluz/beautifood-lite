require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const {
  getTokenAddresses,
  isLocalHost,
  isFork,
  //isL2,
  isGorli,
} = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const main = async () => {
  const dBeautifoodL2 = await deployWithConfirmation("BeautifoodL2");
};

main.id = "000_core";
//main.skip = () => !isL2;
main.skip = () => !isGorli;
module.exports = main;
