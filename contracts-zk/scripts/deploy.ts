import { utils, Wallet, Provider} from 'zksync-web3';
import * as ethers from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { Deployer } from '@matterlabs/hardhat-zksync-deploy';
import dotenv from 'dotenv';
dotenv.config();

export default async function main(hre: HardhatRuntimeEnvironment) {

    const privateKey = process.env.PRIVATE_KEY ?? 'null';
    const zkync_goerli_url = process.env.ZK_GOERLI_URL ?? 'null';
    const wallet = new Wallet(privateKey); 
    // console.log(wallet);
    const provider = new Provider("https://zksync2-testnet.zksync.dev");
    const deployer = new Deployer(hre, wallet);
    console.log(deployer);

    // Variables
    const ZkConnector = "";
    const ZkZetaAddr = "";

    // Deploying baseBeautifood
    const BeautifoodArtifact = await deployer.loadArtifact("Beautifood");
    const beautifood = await deployer.deploy(BeautifoodArtifact, [[ZkConnector], [ZkZetaAddr], 20]);
    console.log(`usdc address: ${beautifood.address}`);

}

  // End of deploying baseBeautifood

  const hre = require("hardhat");
  main(hre).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });