require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const {
  getTokenAddresses,
  isLocalHost,
  isFork,
  //isL1,
  isZetachain,
} = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const deployMockChainlinkPriceFeed = async () => {};

const main = async () => {
  await deployWithConfirmation("BeautifoodZeta", [
    "0x00007d0BA516a2bA02D77907d3a1348C1187Ae62",
    "0x000080383847bd75f91c168269aa74004877592f",
  ]);
  await deployWithConfirmation("USDC", ["US Dollar", "USDC"], "MockERC20");
};

main.id = "000_core";
//main.skip = () => !isL1;
main.skip = () => !isZetachain;
module.exports = main;
