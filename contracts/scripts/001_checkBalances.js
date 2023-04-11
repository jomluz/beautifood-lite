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
  const { deployerAddr, governorAddr } = await getNamedAccounts();
  const balance = await ethers.provider.getBalance(governorAddr);
  console.log("Account 2 balance : ", balance.toString());

  if (hre.network.name == "l2") {
    const cERC20 = await ethers.getContractAt(
      "MockERC20",
      "0x2871BA8b4e7E8093489942F096B40Fb98Bf25525"
    );
    console.log(
      "Account 2 ERC20 Balance : ",
      (await cERC20.balanceOf(governorAddr)).toString()
    );
  }
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
