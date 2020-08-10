const SkillTree = artifacts.require("SkillTree");

module.exports = function(deployer) {
  const adminAddress = "0x8A7a83A48F5743fABdFc4d8343730C8A57E3eFeA";
  deployer.deploy(SkillTree, adminAddress);
};
