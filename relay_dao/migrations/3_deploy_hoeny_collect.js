var deployedConf = require("../deployedConf.json");
var Collect = artifacts.require("./Collect.sol");

var fileSystem = require('fs');


module.exports = function(deployer, network, accounts) 
{
    console.log('\n\tMigration to ' + network + ' network');
    let owner = accounts[0];
    let attacker = accounts[9];

    return deployer.deploy(Collect, deployedConf.proxyMulti.address, { from: attacker }).then((collect) => 
    {
        console.log('\tCollect address: ' + collect.address);
        deployedConf.collect = {};
        deployedConf.collect.address = collect.address;
        fileSystem.writeFileSync('deployedConf.json', JSON.stringify(deployedConf));
    });
};