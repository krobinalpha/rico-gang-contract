import { expect } from "chai";
import { ethers } from "hardhat";


  describe("Deployment", function () {
    it("check Leader functions", async function () {
      const [owner, otherWallet] = await ethers.getSigners();
      const Leader = await ethers.getContractFactory("Leader");
      const leader = await Leader.deploy("Gang Leader", "GLeader");
      await leader.deployed();
      await leader.mint(owner.address, 0);
      await leader.mint(owner.address, 1);
      await leader.mint(owner.address, 2);
      await leader.mint(otherWallet.address, 3);
      await leader.mint(owner.address, 4);
      await leader.mint(otherWallet.address, 5);
      const ownedTokens = await leader.ownedTokens(owner.address, 4);
      expect(ownedTokens).to.equal(4);
    });

  });
