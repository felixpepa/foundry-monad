import { expect } from "chai";
import { ethers } from "hardhat";

describe("CuraToken", function () {
  let curaToken: any;
  let adminManagement: any;
  let owner: any;
  let admin: any;
  let user: any;

  beforeEach(async function () {
    [owner, admin, user] = await ethers.getSigners();
    const AdminManagement = await ethers.getContractFactory("AdminManagement");
    adminManagement = await AdminManagement.deploy();
    await adminManagement.deployed();

    const CuraToken = await ethers.getContractFactory("CuraToken");
    curaToken = await CuraToken.deploy(adminManagement.address);
    await curaToken.deployed();

    await adminManagement.addAdmin(admin.address);
    await curaToken.updateWhitelist(user.address, true);
  });

  it("Should mint tokens to user", async function () {
    await curaToken.connect(admin).mint(user.address, 1000);
    expect(await curaToken.balanceOf(user.address)).to.equal(1000);
  });

  it("Should prevent blacklisted account from receiving tokens", async function () {
    await curaToken.updateBlacklist(user.address, true);
    await expect(
      curaToken.connect(admin).mint(user.address, 1000)
    ).to.be.revertedWith("Transfer to blacklisted account not allowed");
  });
}); 