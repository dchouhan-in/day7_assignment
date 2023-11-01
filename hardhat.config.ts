import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";


const config: HardhatUserConfig = {

  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: process.env.MUMBAI_URL!,
        blockNumber: 41895504,
      },
      chainId: Number(process.env.CHAIN_ID)
    },
    mumbai: {
      url: process.env.MUMBAI_URL,
      chainId: Number(process.env.CHAIN_ID),
      loggingEnabled: true,
      accounts: {
        mnemonic: process.env.MNEMONIC!.split("_").join(" ")
      },
    }
  },
  solidity: {
    compilers: [{
      version: "0.8.20", settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    },
    ]
  },
  paths: {
    sources: "./contracts/weth_dummy",
    tests: "./test/weth",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};

export default config;

require("./scripts/task")