const ZBUX = artifacts.require('ZuckBucks')
const truffleAssert = require('truffle-assertions')

contract('TokenTest', ([owner, account1, account2, account3, ...accounts]) => {

    let token
    let totalsupply

    describe('Contract Deployment and Testing', () => {

        // called before each test
        beforeEach(async () => {
            // deploy ZuckBucks
            token = await ZBUX.new({ from: owner })
            totalsupply = (await token.totalSupply()).toNumber()
        })

        describe('Testing Standard Functionality', () => {
            it('can not transfer more than balance', async () => {
                // give some tokens to account1
                await token.transfer(account1, 100)

                // should not be able to transfer invalid amounts
                assert.isNotOk(token.transfer(account2, -1, { from: account1 }))
            })
            it('can not transfer 0 tokens', async () => {
                assert.isNotOk(tx = await token.transfer(account1, 0))
            })
            it('can transfer small amounts', async () => {
                // transfer all the tokens
                assert.isOk(tx = await token.transfer(account1, 10))

                // check balances
                assert.equal((await token.balanceOf(owner)).toNumber(), totalsupply - 10)
                assert.equal((await token.balanceOf(account1)).toNumber(), 10)

                // check event
                await truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                    assert.equal(ev._from, owner)
                    assert.equal(ev._to, account1)
                    assert.equal(ev._value.toNumber(), 10)
                    return true
                })
            })
            it('can transfer total supply', async () => {
                // transfer all the tokens
                assert.isOk(tx = await token.transfer(account1, totalsupply))

                // check balances
                assert.equal((await token.balanceOf(owner)).toNumber(), 0)
                assert.equal((await token.balanceOf(account1)).toNumber(), totalsupply)

                // check event
                await truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                    assert.equal(ev._from, owner)
                    assert.equal(ev._to, account1)
                    assert.equal(ev._value.toNumber(), totalsupply)
                    return true
                })
            })
            it('can approve small amounts', async () => {
                // approve 10 tokens
                assert.isOk(tx = await token.approve(account1, 10))

                // check allowance
                assert.equal((await token.allowance(owner, account1)).toNumber(), 10)

                // check event
                await truffleAssert.eventEmitted(tx, 'Approval', (ev) => {
                    assert.equal(ev._owner, owner)
                    assert.equal(ev._spender, account1)
                    assert.equal(ev._value.toNumber(), 10)
                    return true
                })
            })
            it('can approve amounts larger than balance or supply', async () => {
                // approve 10 tokens
                assert.isOk(tx = await token.approve(account1, 2 ** 256 - 1))

                // check allowance
                assert.equal((await token.allowance(owner, account1)).toNumber(), 2 ** 256 - 1)

                // check event
                await truffleAssert.eventEmitted(tx, 'Approval', (ev) => {
                    assert.equal(ev._owner, owner)
                    assert.equal(ev._spender, account1)
                    assert.equal(ev._value.toNumber(), 2 ** 256 - 1)
                    return true
                })
            })
            it('can not transferFrom tokens greater than allowance amount', async () => {
                assert.isNotOk(tx = await token.transferFrom(owner, account2, 100, { from: account1 }))
            })
            it('can not transferFrom tokens greater than balance amount', async () => {
                // approve 100 tokens
                assert.isOk(tx = await token.approve(account2, 100, { from: account1 }))

                // do an invalid transferFrom
                assert.isNotOk(tx = await token.transferFrom(account1, account3, 10, { from: account2 }))
            })
            it('can not transferFrom 0 tokens', async () => {
                // approve 100 tokens
                assert.isOk(tx = await token.approve(account1, 100))

                // do an invalid transferFrom
                assert.isNotOk(tx = await token.transferFrom(owner, account3, 0, { from: account1 }))
            })
            it('can do a transferFrom otherwise', async () => {
                // approve 100 tokens
                assert.isOk(tx = await token.approve(account1, 100))

                // do a valid transferFrom
                assert.isOk(tx = await token.transferFrom(owner, account2, 100, { from: account1 }))

                // check allowances
                assert.equal((await token.allowance(owner, account1)).toNumber(), 0)

                // check balances
                assert.equal((await token.balanceOf(owner)).toNumber(), totalsupply - 100)
                assert.equal((await token.balanceOf(account2)).toNumber(), 100)

                // check event
                await truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                    assert.equal(ev._from, owner)
                    assert.equal(ev._to, account2)
                    assert.equal(ev._value.toNumber(), 100)
                    return true
                })
            })
        })
    })
})