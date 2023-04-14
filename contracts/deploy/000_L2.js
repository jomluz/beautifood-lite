require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const {
  getTokenAddresses,
  isLocalHost,
  isFork,
  isL2,
} = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log,
} = require("../utils/deploy");

const main = async () => {
  const { deployerAddr, governorAddr } = await getNamedAccounts();
  const sGovernor = await ethers.getSigner(governorAddr);
  const sDeployer = await ethers.getSigner(deployerAddr);
  log("sending gas to account 2");
  await withConfirmation(
    sDeployer.sendTransaction({
      to: governorAddr,
      value: 10000000000000,
    })
  );
  const dBeautifoodL2 = await deployWithConfirmation("BeautifoodL2");
  const dUSDC = await deployWithConfirmation(
    "USDC",
    ["USD Coin", "USDC"],
    "MockERC20"
  );
  const cBeautifood = await ethers.getContractAt(
    "BeautifoodL2",
    dBeautifoodL2.address
  );
  const cUSDC = await ethers.getContractAt("MockERC20", dUSDC.address);
  log("Setting payment token in beautifood");
  await withConfirmation(cBeautifood.setPaymentToken(dUSDC.address));
  log("Minting tokens to account 2");
  await withConfirmation(cUSDC.mint(governorAddr, 100000000));
  console.log("Adding store to whitelist : ", deployerAddr);
  await withConfirmation(cBeautifood.addStoreToWhitelist(deployerAddr));
  console.log("Submitting a menu to store : ", deployerAddr);

  const menuList = [
    {
      name: "Item1",
      price: 10,
    },
    {
      name: "Item2",
      price: 15,
    },
    {
      name: "Item3",
      price: 20,
    },
    {
      name: "Item4",
      price: 25,
    },
    {
      name: "Item5",
      price: 30,
    },
  ];

  await withConfirmation(cBeautifood.updateMenu(menuList));

  const menu = await cBeautifood.getMenu(deployerAddr);
  log("menu has been updated as follow");
  log(menu);

  const order = [
    {
      id: 0,
      qty: 2,
    },
    {
      id: 1,
      qty: 3,
    },
  ];
  log("making and paying for this order");
  log(order);
  const costOfOrder = await cBeautifood.getTotalPriceOfOrder(
    order,
    deployerAddr
  );
  console.log("order cost: ", costOfOrder.toString());
  console.log(
    "contract balance before submission : ",
    (await cUSDC.balanceOf(cBeautifood.address)).toString()
  );
  console.log(
    "user balance before submission : ",
    (await cUSDC.balanceOf(governorAddr)).toString()
  );
  log("approving tokens");
  await withConfirmation(
    cUSDC.connect(sGovernor).approve(cBeautifood.address, costOfOrder)
  );
  log("submitting order");
  await withConfirmation(
    cBeautifood.connect(sGovernor).submitOrder(order, deployerAddr)
  );
  console.log(
    "contract balance after submission : ",
    (await cUSDC.balanceOf(cBeautifood.address)).toString()
  );
  console.log(
    "user balance after submission : ",
    (await cUSDC.balanceOf(governorAddr)).toString()
  );
};

main.id = "000_L2";
main.skip = () => false; // !l2
module.exports = main;
