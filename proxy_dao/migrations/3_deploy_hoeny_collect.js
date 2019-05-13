var deployedConf = require("../deployedConf.json");
var HoneyPotCollect = artifacts.require("./HoneyPotCollect.sol");

var fileSystem = require('fs');


module.exports = function(deployer, network, accounts) 
{
    console.log('\n\tMigration to ' + network + ' network');
    let owner = accounts[0];
    let attacker = accounts[9];

    return deployer.deploy(HoneyPotCollect, deployedConf.upgradabilityProxy.address, { from: attacker }).then((honeypotCollect) => 
    {
        console.log('\thoneypotCollect address: ' + honeypotCollect.address);
        deployedConf.honeypotCollect = {};
        deployedConf.honeypotCollect.address = honeypotCollect.address;
        fileSystem.writeFileSync('deployedConf.json', JSON.stringify(deployedConf));
    });
};