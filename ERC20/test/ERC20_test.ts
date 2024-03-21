// import {ethers} from "ethers";
const { expect } = require("chai");

// Test case for ERC20 token
describe("ERC20Token", async function () {
  let ERC20Token;
  let token:any;
  let owner:any;
  let addr1:any;
  let addr2:any;

  // Deploy the ERC20 token before each test
  beforeEach(async function () {
    
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy ERC20 Token contract
    ERC20Token = await ethers.getContractFactory("SampleToken");
    token = await ERC20Token.deploy(owner);
  });

  // Test case for basic token information
  it("Should return the correct token name, symbol, and decimals", async function () {
    expect(await token.name()).to.equal("Sample Token");
    expect(await token.symbol()).to.equal("ST");
    expect(await token.decimals()).to.equal(18);
  });

  // Test case for balance of accounts
  it("Should return the correct balance for owner", async function () {
    expect(await token.balanceOf(owner.address)).to.equal(ethers.parseUnits("1000000"));
  });

  // Test case for transfer
  it("Should transfer tokens between accounts", async function () {
    await token.transfer(addr1.address, ethers.parseUnits("100000"));
    expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseUnits("100000"));
    expect(await token.balanceOf(owner.address)).to.equal(ethers.parseUnits("900000"));
  });

  // Test case for transferFrom
  it("Should allow approved accounts to transfer tokens on behalf of the owner", async function () {
    // Approve addr1 to spend tokens on behalf of owner
    await token.approve(addr1.address, ethers.parseUnits("50000"));

    // Transfer tokens from owner to addr2 using addr1's allowance
    await token.connect(addr1).transferFrom(owner.address, addr2.address, ethers.parseUnits("50000"));

    // Ensure balance deduction from owner
    expect(await token.balanceOf(owner.address)).to.equal(ethers.parseUnits("950000"));

    // Ensure balance addition for addr2
    expect(await token.balanceOf(addr2.address)).to.equal(ethers.parseUnits("50000"));

    // Ensure allowance deduction from addr1
    expect(await token.allowance(owner.address, addr1.address)).to.equal(ethers.parseUnits("0"));
  });

  // Test case for mint
  it("Should mint new tokens", async function () {
    // Mint new tokens to addr1
    await token.mint(addr1.address, ethers.parseUnits("50000"));

    // Ensure balance addition for addr1
    expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseUnits("50000"));

    // Ensure total supply increase
    expect(await token.totalSupply()).to.equal(ethers.parseUnits("1050000"));
  });

  // Test case for total supply
  it("Should return the correct total supply", async function () {
    expect(await token.totalSupply()).to.equal(ethers.parseUnits("1000000"));
  });
});
