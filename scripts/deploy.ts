import { ethers, run } from "hardhat";
import { WETH } from "../typechain-types";

async function main() {

  const contract: WETH = await ethers.deployContract("WETH");

  await contract.waitForDeployment();

  console.log(
    `contract deployed for token - , ${await contract.name()} | ${await contract.symbol()}`
  );

  console.log("Address - ", await contract.getAddress());

  await run("verify:verify", {
    address: await contract.getAddress()
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
