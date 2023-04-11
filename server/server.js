const express = require("express");
const { Express, Request, Response } = express;
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const { MongoClient } = require("mongodb");
const morganBody = require("morgan-body");
const bodyParser = require("body-parser");
const cors = require("cors");
const mainArtifact = require("./contracts/L1/BeautifoodCore.sol/Beautifood.json");
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

// websocket
const wsProvider = new ethers.providers.WebSocketProvider("ws://0.0.0.0:8546/");
const contract = new ethers.Contract(
  "0x3dECe9c4fAc1f7762Ec40f1743bFfcC53e20C184",
  mainArtifact.abi,
  wsProvider
);

contract.on("DepositETH", async (from, value, event) => {
  console.log(event);
});

app.listen(port, () => {
  console.log(`⚡️[server]: Server is running at https://localhost:${port}`);
});
