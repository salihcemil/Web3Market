const { inputToConfig } = require('@ethereum-waffle/compiler');
const { expect } = require('chai');
const { arrayify } = require('ethers/lib/utils');
const { ethers } = require('hardhat');
const { BigNumber } = require('ethers');

describe('ERC20Pay', () => {
    let [owner, acc1, acc2, acc3, acc4] = [];
    let Contract;
    let token1, token2;

    beforeEach(async () => {
        [owner, acc1, acc2, acc3, acc4] = await ethers.getSigners();

        Contract = await ethers.getContractFactory("ERC20Pay");
        tokenContract = await ethers.getContractFactory("testToken");

        const factoryToken1 = tokenContract.connect(acc1);
        const factoryToken2 = tokenContract.connect(acc2)
        token1 = await factoryToken1.deploy("testToken1", "TT1");
        token2 = await factoryToken2.deploy("testToken2", "TT2");
        //var balance = await token1.balanceOf(acc1.getAddress());
        //balance = await token2.balanceOf(acc1.getAddress());

        sampleContract= await Contract.deploy(token1.address, acc3.getAddress(), "USDT");
    });

    it('Should be deployed correctly', async function () {
        const name = await sampleContract.getName();
        expect(name).to.equal('ERC20Pay');
    });

    it('Should have correct owner', async function () {
        const contractOwner = await sampleContract.getOwner();
        expect(contractOwner).to.equal(await owner.getAddress());
    });

    it('Adds new currency', async function () {
        await sampleContract.addCurrency(token2.address, acc4.getAddress(), "USDC");
        const currency = await sampleContract.getCurrency(token2.address);
        expect(currency.name).to.equal('USDC');
    });

    it('Adds new item', async function () {
        const itemId = await sampleContract.addItem("item1", token1.address, 1000);
        var value = BigNumber.from(itemId.value);
        var item = await sampleContract.getItem(value);
        expect(value).to.equal(BigNumber.from(item.itemId));
    });

    it('Deactivates item', async function () {
        const itemId = await sampleContract.addItem("item1", token1.address, 1000);
        var value = BigNumber.from(itemId.value);
        const result = await sampleContract.deactivateItem(value);
        
        var item = await sampleContract.getItem(value);
        expect(item.available).to.be.false;
    });

    it('disables currency', async function () {
        const result = await sampleContract.disableCurrency(token1.address);
        var currency = await sampleContract.getCurrency(token1.address);
        expect(currency.isActive).to.be.false;
    });

    it('updates payee address of currency', async function () {
        var currency = await sampleContract.getCurrency(token1.address);
        var firstPayee = currency.payeeAddress;
        var currency = await sampleContract.updatePayeeAddressOfCurrency(token1.address, acc4.getAddress());
        currency = await sampleContract.getCurrency(token1.address);
        var secondPayee = currency.payeeAddress;
        expect(firstPayee).to.be.not.equal(secondPayee);
    });

    it('buys item', async function () {
        const itemId = await sampleContract.addItem("item1", token1.address, 1000);
        var value = BigNumber.from(itemId.value);

        await token1.connect(acc1).approve(sampleContract.address, 1000);

        //payer: acc1, payee: acc3
        await expect(await sampleContract.connect(acc1).buyItem(value)).to.emit(sampleContract, "ItemBought").withArgs(value, await acc1.getAddress(), 1000);
    });

});


for(var i=0; i < arrayify.length; i++){
    
}