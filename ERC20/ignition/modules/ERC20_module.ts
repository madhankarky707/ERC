import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC20",(m) => {
  const owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const token = m.contract("SampleToken",[owner]);

  m.call(token, "balanceOf", [owner]);

  return { token };
});