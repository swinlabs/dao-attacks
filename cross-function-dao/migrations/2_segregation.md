
var HoneyPotLogic = artifacts.require("./HoneyPotLogic.sol");
var HoneyPotAttack = artifacts.require("./HoneyPotAttack.sol");
var HoneyPotData = artifacts.require('HoneyPotData.sol');
var fileSystem = require('fs');

module.exports = function(deployer, network, accounts) 
{
   console.log('\n\tMigration to ' + network + ' network');

   let owner = accounts[0];
   let attacker = accounts[9];
   let dataAddr = accounts[2];

   deployer.deploy(HoneyPotData, {from: dataAddr}).then((honeyPotData) => {
      console.log(`deploy honeyPotData success ${honeyPotData.address}`);
      deployer.deploy(HoneyPotLogic, honeyPotData.address, { from: owner }).then((honeyPotLogic) =>{
         console.log(`deploy honeyPotLogic success ${honeyPotLogic.address}`);
            deployer.deploy(HoneyPotAttack, honeyPotLogic.address, { from: attacker }).then((honeyPotAttack) =>{
            console.log(`deploy honeyPotAttack success ${honeyPotLogic.address}`);
            fileSystem.writeFileSync('honeyPotData.address.json', JSON.stringify({ 'honeyPotData': honeyPotData.address }));
            fileSystem.writeFileSync('honeyPotLogic.address.json', JSON.stringify({ 'honeyPotLogic': honeyPotLogic.address }));
            fileSystem.writeFileSync('honeyPotAttack.address.json', JSON.stringify({ 'honeyPotAttack': honeyPotAttack.address }));
         })
      })
   })
   // deployer.deploy(HoneyPotLogic, { from: owner }).then((honeyPotLogic) => 
   // {
   //    console.log('\thoneyPotLogic address: ' + honeyPotLogic.address);
   //    fileSystem.writeFileSync('honeyPotLogic.address.json', JSON.stringify({ 'honeyPotLogic': honeyPotLogic.address }));

   //    return deployer.deploy(HoneyPotAttack, honeyPotLogic.address, { from: attacker }).then((honeyPotAttack) => 
   //    {
   //          console.log('\thoneyPotAttack address: ' + honeyPotAttack.address);
   //          fileSystem.writeFileSync('honeyPotAttack.address.json', JSON.stringify({ 'honeyPotAttack': honeyPotAttack.address }));
   //    });
   // });
};