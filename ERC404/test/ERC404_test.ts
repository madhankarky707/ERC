// Import necessary modules from Hardhat
const { expect } = require("chai");
const { ethers } = require("hardhat");

// Describe the test suite
describe("Sample404", function () {
  let SampleNFT;
  let sampleNFT:any;
  let owner:any;
  let addr1:any;
  let addr2:any;
  let addr3:any;

  // Deploy the contract before each test
  beforeEach(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    // Deploy Sample404 contract
    SampleNFT = await ethers.getContractFactory("Sample404");
    sampleNFT = await SampleNFT.deploy(owner);
  });

  // Test case for balance of accounts
  it("Should return the correct balance for owner", async function () {
    expect(await sampleNFT.balanceOf(owner.address)).to.equal(ethers.parseUnits("1000000"));
  });

  // Test case for transfer
  it("Should transfer tokens between accounts", async function () {
    await sampleNFT.transfer(addr1.address, ethers.parseUnits("100"));
    expect(await sampleNFT.balanceOf(addr1.address)).to.equal(ethers.parseUnits("100"));
    expect(await sampleNFT.balanceOf(owner.address)).to.equal(ethers.parseUnits("999900"));
  });

  // Test case for transferFrom
  it("Should allow approved accounts to transfer tokens on behalf of the owner", async function () {
    // Approve addr1 to spend tokens on behalf of owner
    await sampleNFT.approve(addr1.address, ethers.parseUnits("5"));

    // Transfer tokens from owner to addr2 using addr1's allowance
    await sampleNFT.connect(addr1).transferFrom(owner.address, addr2.address, ethers.parseUnits("5"));

    // Ensure balance deduction from owner
    expect(await sampleNFT.balanceOf(owner.address)).to.equal(ethers.parseUnits("999995"));

    // Ensure balance addition for addr2
    expect(await sampleNFT.balanceOf(addr2.address)).to.equal(ethers.parseUnits("5"));

    // Ensure allowance deduction from addr1
    expect(await sampleNFT.allowance(owner.address, addr1.address)).to.equal(ethers.parseUnits("0"));
  });

  // Test case for transfer and NFT creation
  it("Should list token ids", async function () {
    await sampleNFT.connect(owner).transfer(addr1.address,ethers.parseUnits("1"));
    const mintedId = String(await sampleNFT.minted());
    const ownerOfNFT = String(await sampleNFT.ownerOf(mintedId));
    const balanceErc20 = String(await sampleNFT.balanceOf(addr1.address));
    expect(mintedId).to.equal("1");
    expect(ownerOfNFT).to.equal(addr1.address);
    expect(balanceErc20).to.equal(String(ethers.parseUnits("1")));
  });

  // Test case for ERC721URIStorage
  it("Should set and get token URI", async function () {
    // Mint a NFT
    await sampleNFT.connect(owner).transfer(addr1.address,ethers.parseUnits("1"));

    // Set and get token URI
    await sampleNFT.setTokenURI(1, "https://example.com/token/0");
    const tokenURI = await sampleNFT.tokenURI(1);
    expect(tokenURI).to.equal("https://example.com/token/0");
  });

  // Test case for transferFrom function
  it("Should transfer token from approved address to another address", async function () {
    // Mint a token and approve addr2 to transfer it
    await sampleNFT.connect(owner).transfer(addr1.address,ethers.parseUnits("1"));
    await sampleNFT.connect(addr1).approve(addr2.address, 1);

    // Transfer the token from owner to addr3 using addr2's approval
    await sampleNFT.connect(addr2).transferFrom(addr1.address, addr3.address, 1);

    // Check the owner of the token
    expect(await sampleNFT.ownerOf(1)).to.equal(addr3.address);
  });

  // Test case for approve function
  it("Should approve an address to transfer token", async function () {
    // Mint a token
    await sampleNFT.connect(owner).transfer(addr1.address,ethers.parseUnits("1"));

    // Approve addr2 to transfer the token
    await sampleNFT.connect(addr1).approve(addr2.address, 1);

    // Check the approved address for the token
    expect(await sampleNFT.getApproved(1)).to.equal(addr2.address);
  });
});
