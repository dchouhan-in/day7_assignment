import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.20", settings: {
          optimizer: {
            enabled: false
          }
        }
      }
    ]
  },
  paths: {
    sources: "./contracts/coin",
    tests: "./test"
  },
};

export default config;
