// Import necessary modules from Hardhat
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { expectRevert } = require("@openzeppelin/test-helpers");

// Describe the test suite
describe("SampleNFT1155", function () {
  let SampleNFT1155;
  let sampleNFT1155:any;
  let owner:any;
  let addr1:any;
  let addr2:any;
  const tokenId = 1;
  const tokenAmount = 100;

  // Deploy the contract before each test
  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy SampleNFT1155 contract
    SampleNFT1155 = await ethers.getContractFactory("SampleNFT1155");
    sampleNFT1155 = await SampleNFT1155.deploy(owner);
  });

  // Test case for URI functions
  it("Should perform URI functions", async function () {
    await sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x");
    // Set token URI
    await sampleNFT1155.setURI(tokenId, `https://example.com/token/${tokenId}.json`);

    // Get token URI
    expect(await sampleNFT1155.uri(tokenId)).to.equal("https://example.com/token/1.json");
  });

  // Test case for pausable functions
  it("Should perform pausable functions", async function () {
    // Pause contract
    await sampleNFT1155.pause();

    // Mint should fail when paused
    await expectRevert(sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x"), 'EnforcedPause()');

    // Unpause contract
    await sampleNFT1155.unpause();

    // Mint should succeed after unpausing
    await sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x");
    expect(await sampleNFT1155.balanceOf(addr1.address, tokenId)).to.equal(tokenAmount);
  });

  // Test case for ownable functions
  it("Should perform ownable functions", async function () {
    // Check owner
    expect(await sampleNFT1155.owner()).to.equal(owner.address);

    // Transfer ownership
    await sampleNFT1155.transferOwnership(addr1.address);
    expect(await sampleNFT1155.owner()).to.equal(addr1.address);
  });

  // Test case for minting tokens
  it("Should mint tokens", async function () {
    // Mint new tokens
    await sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x");

    // Check balance
    expect(await sampleNFT1155.balanceOf(addr1.address, tokenId)).to.equal(tokenAmount);
  });

  // Test case for burning tokens
  it("Should burn tokens", async function () {
    // Mint tokens first
    await sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x");

    // Burn tokens
    await sampleNFT1155.connect(addr1).burn(addr1.address, tokenId, tokenAmount);

    // Check balance
    expect(await sampleNFT1155.balanceOf(addr1.address, tokenId)).to.equal(0);
  });

  // Test case for transferring tokens
  it("Should transfer tokens", async function () {
    // Mint tokens first
    await sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x");

    // Transfer tokens
    await sampleNFT1155.connect(addr1).safeTransferFrom(addr1.address, addr2.address, tokenId, tokenAmount, "0x");

    // Check balances
    expect(await sampleNFT1155.balanceOf(addr1.address, tokenId)).to.equal(0);
    expect(await sampleNFT1155.balanceOf(addr2.address, tokenId)).to.equal(tokenAmount);
  });

  // Test case for approving tokens
  it("Should approve tokens", async function () {
    // Mint tokens first
    await sampleNFT1155.mint(addr1.address, tokenId, tokenAmount, "0x");

    // Approve tokens
    await sampleNFT1155.connect(addr1).setApprovalForAll(addr2.address, true);

    // Check approval
    expect(await sampleNFT1155.isApprovedForAll(addr1.address, addr2.address)).to.be.true;
  });
});
