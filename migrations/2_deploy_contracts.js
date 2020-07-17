var FlashExecution = artifacts.require("./FlashExecution.sol");

module.exports = function(deployer) {
  deployer.deploy(FlashExecution);
}

