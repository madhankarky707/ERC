import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const LockModule = buildModule("SampleNFT1155", (m) => {
  const owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const erc1155 = m.contract("SampleNFT1155", [owner]);

  return { erc1155 };
});

export default LockModule;
