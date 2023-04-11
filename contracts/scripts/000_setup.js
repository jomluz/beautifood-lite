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
const { parseEther } = require("ethers/lib/utils");

const main = async () => {
  const { deployerAddr } = await getNamedAccounts();
  const sDeployer = await ethers.getSigner(deployerAddr);
  const cBeautifood = await ethers.getContract("Beautifood");
  await withConfirmation(
    cBeautifood
      .connect(sDeployer)
      .depositETH({ value: parseEther("0.0000000001") })
  );
  console.log("done");
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
