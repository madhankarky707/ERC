// Import necessary modules from Hardhat
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { expectRevert } = require("@openzeppelin/test-helpers");

// Describe the test suite
describe("SampleNFT", function () {
  let SampleNFT;
  let sampleNFT:any;
  let owner:any;
  let addr1:any;
  let addr2:any;

  // Deploy the contract before each test
  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy SampleNFT contract
    SampleNFT = await ethers.getContractFactory("SampleNFT");
    sampleNFT = await SampleNFT.deploy(owner);
  });

  // Test case for basic functionalities
  it("Should perform basic functions", async function () {
    // Check owner
    expect(await sampleNFT.owner()).to.equal(owner.address);

    // Mint a new token
    await sampleNFT.safeMint(addr1.address);
    expect(await sampleNFT.ownerOf(0)).to.equal(addr1.address);

    // Pause and unpause contract
    await sampleNFT.pause();
    expect(await sampleNFT.paused()).to.equal(true);
    await sampleNFT.unpause();
    expect(await sampleNFT.paused()).to.equal(false);

    // Burn a token
    await sampleNFT.connect(addr1).burn(0);
    await expectRevert(sampleNFT.ownerOf(0), "ERC721NonexistentToken(0)");
  });

  // Test case for ERC721Enumerable
  it("Should list token ids", async function () {
    // Mint some tokens
    await sampleNFT.safeMint(addr1.address);
    await sampleNFT.safeMint(addr1.address);
    await sampleNFT.safeMint(addr1.address);

    // Check token ids
    const tokenIds = String(await sampleNFT._nextTokenId());
    expect(tokenIds).to.equal("3");
  });

  // Test case for ERC721URIStorage
  it("Should set and get token URI", async function () {
    // Mint a token
    await sampleNFT.safeMint(addr1.address);

    // Set and get token URI
    await sampleNFT.setTokenURI(0, "https://example.com/token/0");
    const tokenURI = await sampleNFT.tokenURI(0);
    expect(tokenURI).to.equal("https://example.com/token/0");
  });

  // Test case for ERC721Pausable
  it("Should revert when pausing and unpausing as non-owner", async function () {
    // Attempt to pause as non-owner
    await expectRevert(sampleNFT.connect(addr1).pause(), 'OwnableUnauthorizedAccount("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")');
    // Pause and attempt to unpause as non-owner
    await sampleNFT.pause();
    await expectRevert(sampleNFT.connect(addr1).unpause(), 'OwnableUnauthorizedAccount("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")');
  });

  // Test case for ERC721Burnable
  it("Should revert when burning non-existent token", async function () {
    // Attempt to burn non-existent token
    await expectRevert(sampleNFT.burn(1),"ERC721NonexistentToken(1)");
  });

  // Test case for transferFrom function
  it("Should transfer token from approved address to another address", async function () {
    // Mint a token and approve addr1 to transfer it
    await sampleNFT.safeMint(owner.address);
    await sampleNFT.approve(addr1.address, 0);

    // Transfer the token from owner to addr2 using addr1's approval
    await sampleNFT.connect(addr1).transferFrom(owner.address, addr2.address, 0);

    // Check the owner of the token
    expect(await sampleNFT.ownerOf(0)).to.equal(addr2.address);
  });

  // Test case for approve function
  it("Should approve an address to transfer token", async function () {
    // Mint a token
    await sampleNFT.safeMint(owner.address);

    // Approve addr1 to transfer the token
    await sampleNFT.approve(addr1.address, 0);

    // Check the approved address for the token
    expect(await sampleNFT.getApproved(0)).to.equal(addr1.address);
  });


  // Additional test cases can be added as needed
});
