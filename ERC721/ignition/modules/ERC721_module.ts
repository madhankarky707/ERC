import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC721",(m) => {
  const owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const token = m.contract("SampleNFT",[owner]);

  m.call(token, "safeMint", [owner]);

  return { token };
});