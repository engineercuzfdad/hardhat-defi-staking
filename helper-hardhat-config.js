const networkConfig = {
  default: {
    name: "hardhat",
  },
  31337: {
    name: "localhost",
    daiEthPriceFeed: "0x773616E4d11A78F511299002da57A0a94577F1f4",
    btcEthPriceFeed: "0xdeb288F737066589598e9214E782fa5A8eD689e8",
  },
  4: {
    name: "sepolia",
    daiUsdPriceFeed: "0x14866185B1962B63C3Ea9E03Bc1da838bab34C19",
    btcUsdPriceFeed: "0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43",
    ethUsdPriceFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
  },
};

const developmentChains = ["hardhat", "localhost"];
const VERIFICATION_BLOCK_CONFIRMATIONS = 6;

module.exports = {
  networkConfig,
  developmentChains,
  VERIFICATION_BLOCK_CONFIRMATIONS,
};
