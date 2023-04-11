require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const { getTokenAddresses, isFork } = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const deployDummyToken = async () => {
  const { deployerAddr, governorAddr } = await getNamedAccounts();
  await deployWithConfirmation("DummyToken", ["Test Token", "TEST"]);
  const cDummyToken = await ethers.getContract("DummyToken");
  const cMockChainlinkOracleFeed = await ethers.getContract(
    "MockChainlinkOracleFeed"
  );

  try {
    await withConfirmation(
      cDummyToken["setPriceFeed"](cMockChainlinkOracleFeed.address)
    );
  } catch (e) {
    console.log("already set");
  }
  await withConfirmation(cMockChainlinkOracleFeed.setDecimals("8"));
};

const deployUserRegistry = async () => {
  const { deployerAddr, governorAddr } = await getNamedAccounts();
  const sGovernor = await ethers.provider.getSigner(governorAddr);
  const sDeployer = await ethers.provider.getSigner(deployerAddr);
  await deployWithConfirmation("UserRegistry");
  const cUserRegistry = await ethers.getContract("UserRegistry");
};

const main = async () => {
  await deployDummyToken();
  await deployUserRegistry();
};

main.id = "001_core";
main.skip = () => false;
module.exports = main;
