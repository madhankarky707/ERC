// import {ethers} from "ethers";
const { expect } = require("chai");
const {
  constants,
  expectRevert
} = require('@openzeppelin/test-helpers');

describe("GameMaster Contract", async function () {
  let GameMaster;
  let GameMasterInstance:any;
  let ArmoredForge;
  let ArmoredForgeInstance:any;
  let childArmorId;
  let owner:any;
  let addr1:any;
  let addr2:any;

  // Deploy the ERC721 contracts before each test
  before(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy GameMaster contract
    GameMaster = await ethers.getContractFactory("ValorWar");
    GameMasterInstance = await GameMaster.deploy("ValorWar","WARRIOR");

    // Deploy ArmoredForge contract
    ArmoredForge = await ethers.getContractFactory("ArmoredForge");
    ArmoredForgeInstance = await ArmoredForge.deploy("ArmoredForge","ARMOR");
  });

  // Test case for verifying the token information of ValorWar
  it("Should return the correct token name and symbol for ValorWar", async function () {
    expect(await GameMasterInstance.name()).to.equal("ValorWar");
    expect(await GameMasterInstance.symbol()).to.equal("WARRIOR");
  });

  // Test case for verifying the token information of ArmoredForge
  it("Should return the correct token name and symbol for ArmoredForge", async function () {
    expect(await ArmoredForgeInstance.name()).to.equal("ArmoredForge");
    expect(await ArmoredForgeInstance.symbol()).to.equal("ARMOR");
  });

  // Test case for verifying the creation of warriors
  it("Should create warriors and assign them to the owner", async function () {
    expect(await GameMasterInstance.balanceOf(owner.address)).to.equal(4);
    for (let i = 1; i <= 4; i++) {
      expect(await GameMasterInstance.ownerOf(i)).to.equal(owner.address);
    }
  });

  // Test case for verifying the creation of armor
  it("Should create armor and assign them to the owner", async function () {
    expect(await ArmoredForgeInstance.balanceOf(owner.address)).to.equal(9);
    for (let i = 1; i <= 9; i++) {
      expect(await ArmoredForgeInstance.ownerOf(i)).to.equal(owner.address);
    }
  });

  // Test case for spawning a new warrior
  it("Should spawn a new warrior and assign it to the specified address", async function () {
    const newWarriorId = 5;
    const warriorURI = "https://example.com/warrior/5";
    await GameMasterInstance.spawnWarrior(addr1.address, warriorURI);
    expect(await GameMasterInstance.balanceOf(addr1.address)).to.equal(1);
    expect(await GameMasterInstance.ownerOf(newWarriorId)).to.equal(addr1.address);
  });

  // Test case for spawning a new warrior
  it("Should spawn a new warrior and assign it to the specified address", async function () {
    const newWarriorId = 6;
    const warriorURI = "https://example.com/warrior/6";
    await GameMasterInstance.spawnWarrior(addr2.address, warriorURI);
    expect(await GameMasterInstance.balanceOf(addr2.address)).to.equal(1);
    expect(await GameMasterInstance.ownerOf(newWarriorId)).to.equal(addr2.address);
  });

  // Test case for forging new armor
  it("Should forge new armor and assign it to the specified address", async function () {
    const newArmorId = 10;
    const armorURI = "https://example.com/armor/10";
    await ArmoredForgeInstance.forgeArmor(addr1.address, armorURI);
    expect(await ArmoredForgeInstance.balanceOf(addr1.address)).to.equal(1);
    expect(await ArmoredForgeInstance.ownerOf(newArmorId)).to.equal(addr1.address);
  });

  // Test case for adding armor to a warrior
  it("Should add armor to a warrior", async function () {
    const parentWarriorId = 5;
    const armorId = 1;
    await ArmoredForgeInstance.addArmorToWarrior(owner.address, GameMasterInstance.target, armorId, parentWarriorId, constants.ZERO_BYTES32);
    const armorOwner = await ArmoredForgeInstance.directOwnerOf(armorId);
    const pendingArmor = await GameMasterInstance.pendingChildOf(parentWarriorId, 0);
    expect(armorOwner.owner_).to.equal(GameMasterInstance.target);
    expect(await ArmoredForgeInstance.ownerOf(armorId)).to.equal(addr1.address);
    expect(pendingArmor[0]).to.equal(armorId);
    expect(pendingArmor[1]).to.equal(ArmoredForgeInstance.target);
  });

  // Test case for accepting armor by a warrior
  it("Should accept armor by a warrior", async function () {
    const warriorId = 5;
    const armorId = 1;
    await GameMasterInstance.connect(addr1).acceptChild(warriorId, 0, ArmoredForgeInstance.target, armorId);
    const activeArmor = await GameMasterInstance.childOf(warriorId, 0);
    expect(activeArmor[0]).to.equal(armorId);
    expect(activeArmor[1]).to.equal(ArmoredForgeInstance.target);
  });

  // Test case for transferring armor from one warrior to another
  it("Should transfer armor from one warrior to another", async function () {
    const parentWarriorId = 5;
    const warriorId = 6;
    const armorId = 1;
    await GameMasterInstance.connect(addr1).transferArmor(parentWarriorId, GameMasterInstance.target, warriorId, 0, ArmoredForgeInstance.target, armorId, false, constants.ZERO_BYTES32);
    const pendingArmor = await GameMasterInstance.pendingChildOf(warriorId, 0);
    expect(await ArmoredForgeInstance.ownerOf(armorId)).to.equal(addr2.address);
    expect(pendingArmor[0]).to.equal(armorId);
    expect(pendingArmor[1]).to.equal(ArmoredForgeInstance.target);
  });

  // Test case for destroying a warrior
  it("Should destroy a warrior", async function () {
    const warriorId = 6;
    await GameMasterInstance.connect(addr2).destroyWarrior(warriorId);
    await expectRevert(
      ArmoredForgeInstance.ownerOf(1),
      'ERC721InvalidTokenId()',
    );
    await expectRevert(
      GameMasterInstance.ownerOf(warriorId),
      'ERC721InvalidTokenId()',
    );
  });
});
