require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const {
  getTokenAddresses,
  isLocalHost,
  isFork,
  //isL2,
  isGoerli,
} = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const main = async () => {
  const dBeautifood = await deployWithConfirmation("Beautifood", [
    "0x00007d0BA516a2bA02D77907d3a1348C1187Ae62",
    "0xCc7bb2D219A0FC08033E130629C2B854b7bA9195",
    7001,
  ]);
};

main.id = "000_core";
//main.skip = () => !isL2;
main.skip = () => !isGoerli;
module.exports = main;
