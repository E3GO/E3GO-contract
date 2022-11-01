const hre = require("hardhat");

async function main() {
  // Mumbai
  //const priceFeed_EURUSD = "0x7d7356bF6Ee5CDeC22B216581E48eCC700D0497A"
  //const priceFeed_MATICUSD = "0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada"

  // Polygon
  const priceFeed_EURUSD = "0xAB594600376Ec9fD91F8e885dADF0CE036862dE0"
  const priceFeed_MATICUSD = "0x73366Fe0AA0Ded304479862808e02506FE556a98"

  const Proxy = await hre.ethers.getContractFactory("tGHP");
  const proxy = await upgrades.deployProxy(Proxy, [priceFeed_MATICUSD, priceFeed_EURUSD]);

  await proxy.deployed();

  console.log(
    `Proxy with data feed (Mumbai) ${priceFeed_MATICUSD, priceFeed_EURUSD} deployed to ${proxy.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
