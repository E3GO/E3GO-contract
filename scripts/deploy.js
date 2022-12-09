const hre = require("hardhat");
const ERC1967Proxy = require('@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol/ERC1967Proxy.json')

async function main() {
  // Mumbai
  //const priceFeed_EURUSD = "0x7d7356bF6Ee5CDeC22B216581E48eCC700D0497A"
  //const priceFeed_MATICUSD = "0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada"

  // Polygon
  const priceFeed_EURUSD = "0xAB594600376Ec9fD91F8e885dADF0CE036862dE0"
  const priceFeed_MATICUSD = "0x73366Fe0AA0Ded304479862808e02506FE556a98"

  const Imp = await hre.ethers.getContractFactory("E3GO")
  const Proxy = await hre.ethers.getContractFactory(ERC1967Proxy.abi, ERC1967Proxy.bytecode)
  let imp = await Imp.deploy()
  await imp.deployed()
  await imp.initialize(priceFeed_MATICUSD, priceFeed_EURUSD, "0xdec44382EAed2954e170BD2a36381A9B06627332", "IMPLEMENTATION")
  
  /*const fragment = Imp.interface.getFunction("initialize");
  const data = Imp.interface.encodeFunctionData(fragment, [priceFeed_MATICUSD, priceFeed_EURUSD, "0x684F6b7Fd58b27872Fe7ac07375a96630A111742", ""])

  let proxy = await Proxy.deploy(imp.address, data)
  await proxy.deployed()*/

  console.log(
    `Proxy with data feed (Mumbai) ${priceFeed_MATICUSD} - ${priceFeed_EURUSD} deployed to ${imp.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});