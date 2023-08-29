import dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

const accounts = [process.env.PRIVATEKEY || ""];

const config: HardhatUserConfig = {
  networks: {
    arbitrum: {
      url: "https://arb1.arbitrum.io/rpc",
      accounts
    },
    arbitrum_goerli: {
      url: "https://goerli-rollup.arbitrum.io/rpc",
      accounts
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
					optimizer: {
						enabled: true,
						runs: 10000,
					}
        }
      }
    ]
  }
};

export default config;
