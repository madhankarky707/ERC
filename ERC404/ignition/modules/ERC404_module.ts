import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Sample404",(m) => {
  const owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const addr1 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
  const token = m.contract("Sample404",[owner]);

  m.call(token, "transfer", [addr1, ethers.parseUnits("1")]);

  return { token };
});