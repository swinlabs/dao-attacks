

var HoneyPot = artifacts.require("./HoneyPot.sol");
// var HoneyPotCollect = artifacts.require("./HoneyPotCollect.sol");
var UpgradabilityProxy = artifacts.require("./UpgradabilityProxy.sol");

var fileSystem = require('fs');

module.exports = function(deployer, network, accounts) 
{
    console.log('\n\tMigration to ' + network + ' network');

    let owner = accounts[0];
    let attacker = accounts[9];
    let deployedConf = {};
    deployedConf.honeypot = {};
    deployedConf.upgradabilityProxy = {};

    deployer.deploy(HoneyPot, { from: owner }).then((honeypot) => {
        console.log('\thoneypot address: ' + honeypot.address);
        // fileSystem.writeFileSync('deployedConf.json', JSON.stringify({ 'honeypot': honeypot.address }));
        deployedConf.honeypot.address = honeypot.address;
        return deployer.deploy(UpgradabilityProxy, honeypot.address, { from: owner }).then((upgradabilityProxy) => 
        {
            console.log('\tupgradabilityProxy address: ' + upgradabilityProxy.address);
            deployedConf.upgradabilityProxy.address = upgradabilityProxy.address;
            // fileSystem.writeFileSync('upgradabilityProxy.address.json', JSON.stringify({ 'upgradabilityProxy': upgradabilityProxy.address }));
            fileSystem.writeFileSync('deployedConf.json', JSON.stringify(deployedConf));
        });
    });
};


// module.exports = function(deployer, network, accounts) 
// {
//     console.log('\n\tMigration to ' + network + ' network');

//     let owner = accounts[0];
//     let attacker = accounts[9];

//     deployer.deploy(HoneyPot, { from: owner }).then((honeypot) => 
//     {
//         console.log('\thoneypot address: ' + honeypot.address);
//         fileSystem.writeFileSync('honeypot.address.json', JSON.stringify({ 'honeypot': honeypot.address }));

//         return deployer.deploy(HoneyPotCollect, honeypot.address, { from: attacker }).then((honeypotCollect) => 
//         {
//             console.log('\thoneypotCollect address: ' + honeypotCollect.address);
//             fileSystem.writeFileSync('honeypotCollect.address.json', JSON.stringify({ 'honeypotCollect': honeypotCollect.address }));
//         });
//     });
// };