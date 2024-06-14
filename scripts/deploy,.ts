import { ethers } from "hardhat";

async function main() {
  const uri = "https://meu-quarto-digital.com/"; // Replace with your desired URI base
  const deployer = (await ethers.getSigners())[0]; // Get the first signer (deployer)

  const MeuQuartoDigital = await ethers.getContractFactory("MeuQuartoDigital");
  const meuQuartoDigital = await MeuQuartoDigital.deploy(uri, deployer.address);
  await meuQuartoDigital.deployed();
  console.log(`MeuQuartoDigital deployed to ${meuQuartoDigital.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
