import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("Lock", function () {
  async function deploy() {
    const [owner, addr1, addr2] = await hre.ethers.getSigners();

    const MeuQuartoDigital = await hre.ethers.getContractFactory(
      "MeuQuartoDigital"
    );

    // Deploy the contracts
    const meuQuartoDigital = await MeuQuartoDigital.deploy(
      "https://meu-quarto-digital.com/",
      owner
    );

    return {
      meuQuartoDigital,
      owner,
      addr1,
      addr2,
    };
  }

  it("should allow creators to register", async function () {
    const { meuQuartoDigital, owner, addr1, addr2 } = await loadFixture(deploy);

    const subscriptionPrice1 = 100; // Valor da assinatura em ether
    const subscriptionPrice2 = 200; // Valor da assinatura em ether

    await meuQuartoDigital.connect(addr1).registerCreator(subscriptionPrice1);
    await meuQuartoDigital.connect(addr2).registerCreator(subscriptionPrice2);

    const creator1Registered = await meuQuartoDigital.creators(addr1.address);
    const creator2Registered = await meuQuartoDigital.creators(addr2.address);

    expect(creator1Registered.isRegistered).to.be.true;
    expect(creator1Registered.subscriptionPrice).to.equal(subscriptionPrice1);

    expect(creator2Registered.isRegistered).to.be.true;
    expect(creator2Registered.subscriptionPrice).to.equal(subscriptionPrice2);
  });
});
