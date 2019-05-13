

var Fool = artifacts.require("./Fool.sol");
var ProxyMulti = artifacts.require("./ProxyMulti.sol");
var Barr = artifacts.require("./Barr.sol");

var fileSystem = require('fs');

module.exports = function(deployer, network, accounts) 
{
    console.log('\n\tMigration to ' + network + ' network');

    let owner = accounts[0];
    let attacker = accounts[9];
    let deployedConf = {};
    deployedConf.fool = {};
    deployedConf.barr = {};
    deployedConf.proxyMulti = {};
    deployer.deploy(Fool, { from: owner }).then((fool) => {
        console.log('\tfool address: ' + fool.address);
        // fileSystem.writeFileSync('deployedConf.json', JSON.stringify({ 'fool': fool.address }));
        deployedConf.fool.address = fool.address;
        return deployer.deploy(Barr, { from: owner }).then((barr) => 
        {
            console.log('\tbarr address: ' + barr.address);
            deployedConf.barr.address = barr.address;
            // fileSystem.writeFileSync('barr.address.json', JSON.stringify({ 'barr': barr.address }));
            return deployer.deploy(ProxyMulti, fool.address, barr.address, { from: owner }).then((proxyMulti) => {
                console.log('\tproxyMulti address: ' + proxyMulti.address);
                deployedConf.proxyMulti.address = proxyMulti.address;
                fileSystem.writeFileSync('deployedConf.json', JSON.stringify(deployedConf));
            })
        });
    });
};

// abiStringArray = JSON.parse(proxyLogicContract.abiString);
// var functionArrays = [];
// for (var i =0; i < abiStringArray.length; i++) {
//   if (abiStringArray[i].type == "function") {
//      functionArrays.push(abiStringArray[i]);
//   }
// }
// var stringArray = [];
// var functionSignatures = [];
// for (var i =0; i < functionArrays.length; i++) {
//     functionSignatures.push(web3.eth.abi.encodeFunctionSignature(functionArrays[i]));
// //    var functionString = "";
// //    functionString += functionArrays[i].name + "(";
// //    var inputArray = functionArrays[i].inputs;
// //    if (inputArray.length > 0) {
// //      for (var j = 0; j < inputArray.length; j++) {
// //         functionString += inputArray[j].type + ",";
// //      }
// //      functionString = functionString.substr(0, functionString.length - 1);
// //    } 
// //    functionString += ")";
// //    stringArray.push(functionString);
// //    var keccak256OfFunction = web3.utils.keccak256(functionString);
// //    functionSignatures.push(keccak256OfFunction.substr(0, 10));
// }

// module.exports = function(deployer, network, accounts) 
// {
//     console.log('\n\tMigration to ' + network + ' network');

//     let owner = accounts[0];
//     let attacker = accounts[9];

//     deployer.deploy(fool, { from: owner }).then((fool) => 
//     {
//         console.log('\tfool address: ' + fool.address);
//         fileSystem.writeFileSync('fool.address.json', JSON.stringify({ 'fool': fool.address }));

//         return deployer.deploy(foolCollect, fool.address, { from: attacker }).then((foolCollect) => 
//         {
//             console.log('\tfoolCollect address: ' + foolCollect.address);
//             fileSystem.writeFileSync('foolCollect.address.json', JSON.stringify({ 'foolCollect': foolCollect.address }));
//         });
//     });
// };