const express = require("express");
const { Express, Request, Response } = express;
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const { MongoClient } = require("mongodb");
const morganBody = require("morgan-body");
const bodyParser = require("body-parser");
const cors = require("cors");
const mainArtifactL1 = require("./contracts/L1/BeautifoodCore.sol/Beautifood.json");
const mainArtifactL2 = require("./contracts/L2/BeautifoodCore.sol/BeautifoodL2.json");

dotenv.config();

const corsOptions = {
  origin: "http://localhost:3000", // TODO : Add custom domain
  optionsSuccessStatus: 200,
};

const app = express();
const port = process.env.PORT || 9000;

// parse JSON and others

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// log all requests and responses
morganBody(app, { logAllReqHeader: true, maxBodyLength: 5000 });

// rpc
const rpcProvider = new ethers.providers.JsonRpcProvider(
  "http://0.0.0.0:8565/"
);
const mainSigner = new ethers.Wallet(
  process.env.DEPLOYER_PRIVATE_KEY,
  rpcProvider
);
const coreContract = new ethers.Contract(
  process.env.CORE_CONTRACT_ADDR_L2,
  mainArtifactL2.abi,
  mainSigner
);
// websocket
const wsProvider = new ethers.providers.WebSocketProvider("ws://0.0.0.0:8546/");
const contractWss = new ethers.Contract(
  process.env.CORE_CONTRACT_ADDR_L1,
  mainArtifactL1.abi,
  wsProvider
);

console.log(contractWss.address);

contractWss.on("DepositETH", async (sender, amount, event) => {
  console.log("Deposit detected in L1");

  const tx = await mainSigner.sendTransaction({
    to: sender,
    value: amount,
  });

  const receipt = await tx.wait();
  console.log("Deposit settled in L2 with tx ", receipt.transactionHash);
});

contractWss.on("DepositERC20", async (sender, token, amount, other) => {
  console.log("ERC20 Deposit detected in L1");
  console.log("Checking if token exists in L2");
  const rd = await coreContract.ercL1toL2(token);
  if (rd == ethers.constants.AddressZero) {
    console.log("Deploying token to L2");
    const tx = await coreContract.deployNewERC20("Test Token", "Test", token);
    await tx.wait();
    const rd = await coreContract.ercL1toL2(token);
    console.log("Deployed ERC in L2 : ", rd);
  }
  const tx = await coreContract.mintERC20(sender, token, amount);
  const receipt = await tx.wait();
  console.log("ERC20 Deposit settled in L2 with tx ", receipt.transactionHash);
});

app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at https://localhost:${port}`);
});
