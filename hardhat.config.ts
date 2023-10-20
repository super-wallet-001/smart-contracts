import { HardhatUserConfig } from "hardhat/config";
import '@typechain/hardhat';
import "dotenv/config";
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-deploy-tenderly';


const PRIVATE_KEY = process.env.PRIVATE_KEY;
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL;
const POLYSCAN_API_KEY = process.env.POLYSCAN_API_KEY;
const PROVIDER_API_KEY= process.env.ALCHEMY_API_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  defaultNetwork: "hardhat",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    arbitrumGoerli: {
      url: `https://arb-goerli.g.alchemy.com/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    optimism: {
      url: `https://opt-mainnet.g.alchemy.com/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    optimismGoerli: {
      url: `https://opt-goerli.g.alchemy.com/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    polygonMumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    polygonZkEvmTestnet: {
      url: `https://polygonzkevm-testnet.g.alchemy.com/v2/${PROVIDER_API_KEY}`,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev",
      zksync: true,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    zkSync: {
      url: "https://mainnet.era.zksync.io",
      zksync: true,
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    gnosis: {
      url: "https://rpc.gnosischain.com",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    chiado: {
      url: "https://rpc.chiadochain.net",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    base: {
      url: "https://mainnet.base.org",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    baseGoerli: {
      url: "https://goerli.base.org",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    scrollSepolia: {
      url: "https://sepolia-rpc.scroll.io",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    avalancheFuji:{
      url:"https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [process.env.PRIVATE_KEY || ""],
    },
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      chainId: 1337,
    },
  },
  // @ts-ignore
  namedAccounts: {
    deployer: {
      default: 0,
    },
    alice: {
      default: 1,
    },
    ravi: {
      default: 2,
    },
    bob: {
      default: 3,
    },
  }
};

export default config;
