const Migrations = artifacts.require("SaleErc1155");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
