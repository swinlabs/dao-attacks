
var HoneyPot = artifacts.require("./HoneyPot.sol");
var HoneyPotCollect = artifacts.require("./HoneyPotCollect.sol");

var fileSystem = require('fs');

module.exports = function(deployer, network, accounts) 
{
    console.log('\n\tMigration to ' + network + ' network');

    let owner = accounts[0];
    let attacker = accounts[11];

    deployer.deploy(HoneyPot, { from: owner }).then((honeypot) => 
    {
        console.log('\thoneypot address: ' + honeypot.address);
        fileSystem.writeFileSync('honeypot.address.json', JSON.stringify({ 'honeypot': honeypot.address }));

        return deployer.deploy(HoneyPotCollect, honeypot.address, { from: attacker }).then((honeypotCollect) => 
        {
            console.log('\thoneypotCollect address: ' + honeypotCollect.address);
            fileSystem.writeFileSync('honeypotCollect.address.json', JSON.stringify({ 'honeypotCollect': honeypotCollect.address }));
        });
    });
};