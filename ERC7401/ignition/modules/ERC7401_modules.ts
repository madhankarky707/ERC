import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC7401",(m) => {
  const ValorWar = m.contract("ValorWar",["ValorWar","WARRIOR"]);
  const ArmoredForge = m.contract("ArmoredForge",["ArmoredForge","ARMOR"]);
  return { ValorWar, ArmoredForge };
});