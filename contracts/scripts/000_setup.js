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
  const sDeployer = await ethers.getSigner(deployerAddr);
  const sGovernor = await ethers.getSigner(governorAddr);
  const cBeautifood = await ethers.getContract("Beautifood");
  const cUSDC = await ethers.getContract("USDC");
  log("minting token to governor");
  await withConfirmation(cUSDC.connect(sGovernor).mint(governorAddr, 10000));
  //   log("Depositing eth");
  //   await withConfirmation(
  //     cBeautifood
  //       .connect(sGovernor)
  //       .depositETH({ value: parseEther("0.0000000001") })
  //   );
  log("approving tokens");
  await withConfirmation(
    cUSDC.connect(sGovernor).approve(cBeautifood.address, 2000)
  );
  log("depositing ERC20");
  await withConfirmation(
    cBeautifood.connect(sGovernor).depositERC20(2000, cUSDC.address)
  );
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
