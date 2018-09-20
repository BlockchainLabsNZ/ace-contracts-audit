let Ace = artifacts.require("Ace");

const assertFail = require("./helpers/assertFail");
var BN = web3.utils.BN;

contract("Ace", function([owner, investor, investor2, vandal]) {
  let ace;

  beforeEach(async () => {
    ace = await Ace.new();
  });

  it("The owner can turn off and on the sale", async () => {
    assert.equal(await ace._selling.call(), true);
    await ace.turnOffSale({ from: owner });
    assert.equal(await ace._selling.call(), false, "The sale status should have been updated");
    await ace.turnOnSale({from: owner});
    assert.equal(await ace._selling.call(), true);
  });

  it("A vandal can't turn off or on the sale", async () => {
    assert.equal(await ace._selling.call(), true);
    await assertFail(async () => {
      await ace.turnOffSale({ from: vandal });
    })
    await ace.turnOffSale({from:owner});
    assert.equal(await ace._selling.call(), false, "The owner can turn it off");
    await assertFail(async () => {
      await ace.turnOnSale({ from: vandal });
    })
    assert.equal(await ace._selling.call(), false, "The Sale status should not have changed");
  });

  it("The owner can set the buy price", async () => {
    assert.equal(await ace._originalBuyPrice.call(), 2296000000000);
    await ace.setBuyPrice(1, { from: owner });
    assert.equal(await ace._originalBuyPrice.call(), 1, "The buy price should have been updated");
  });

  it("The owner can't set the buy price to 0", async () => {
    assert.equal(await ace._originalBuyPrice.call(), 2296000000000);
    await assertFail(async () => {
      await ace.setBuyPrice(0, { from: owner });
    });
    assert.equal(await ace._originalBuyPrice.call(), 2296000000000, "The buy price should not have changed");
  });

  it("Can't transfer tokens to address(0)", async () => {
    let original_balance = await ace.balanceOf.call(owner);
    await assertFail(async () => {
      await ace.transfer(0x0000000000000000000000000000000000000000, 1000000000, { from: owner });
    });
    assert.equal(await ace.balanceOf.call(owner) - original_balance, 0, "The balance should not have changed");
  });

  it("Total supply should be reduced when tokens are burned", async () => {
    let original_supply = await ace.totalSupply.call();
    await ace.setMaximumBurn(10000000000, { from: owner });
    await ace.burn(10000000000, { from: owner });
    assert.equal(original_supply - (await ace.totalSupply.call()), 10000000000, "Total supply should be decreased");
  });

  it("Investors can purchase Ace Tokens if whitelisted", async () => {
    assert.equal(await ace.balanceOf.call(investor), 0);
    await ace.addInvestorList([investor], { from: owner });
    await ace.buyAce({ from: investor, value: web3.utils.toWei('1', 'ether') });
    assert.equal((await ace.balanceOf.call(investor)).toString(), "1000000000000000000");
    await ace.removeInvestorList([investor],{from:owner});
    await assertFail(async ()=>{
      await ace.buyAce({from:investor, value: web3.utils.toWei('1','ether')});
    });
    assert.equal((await ace.balanceOf.call(investor)).toString(), "1000000000000000000");
  });

  it("Investors can't purchase Ace Tokens if not whitelisted", async () => {
    assert.equal(await ace.balanceOf.call(investor), 0);
    await assertFail(async () => {
      await ace.buyAce({ from: investor, value: web3.utils.toWei('1', 'ether') });
    });
    assert.equal(await ace.balanceOf.call(investor), 0);
  });

  it("The owner can set IcoPercent but a vandal can't", async () =>{
    assert.equal(await ace._icoPercent.call(), 10);
    await ace.setIcoPercent(20,{from: owner});
    assert.equal(await ace._icoPercent.call(), 20, "_icoPercent should be 20");
    await assertFail(async () => {
      await ace.setIcoPercent(15,{from:vandal});
    });
    assert.equal(await ace._icoPercent.call(),20,"_icoPercent shouldn't have changed")
  });

  it("The owner can set minimum buy but a vandal can't", async () =>{
    assert.equal(await ace._minimumBuy.call(), 3E17);
    await ace.setMinimumBuy(4E17,{from: owner});
    assert.equal(await ace._minimumBuy.call(), 4E17, "_icoPercent should be 20");
    await assertFail(async () => {
      await ace.setMinimumBuy(2E17,{from:vandal});
    });
    assert.equal(await ace._minimumBuy.call(),4E17,"_icoPercent shouldn't have changed")
  });

  it("The owner can set maximum buy but a vandal can't", async () =>{
    assert.equal((await ace._maximumBuy.call()).toString(), '10888501742160278745');
    await ace.setMaximumBuy(26E18,{from: owner});
    assert.equal(await ace._maximumBuy.call(), 26E18, "_icoPercent should be 20");
    await assertFail(async () => {
      await ace.setMaximumBuy(30E18,{from:vandal});
    });
    assert.equal(await ace._maximumBuy.call(),26E18,"_icoPercent shouldn't have changed")
  });

  it("The owner can set maximum burn but a vandal can't", async () =>{
    assert.equal(await ace._maximumBurn.call(), 0);
    await ace.setMaximumBurn(30E18,{from: owner});
    assert.equal(await ace._maximumBurn.call(), 30E18, "_icoPercent should be 20");
    await assertFail(async () => {
      await ace.setMaximumBurn(40E18,{from:vandal});
    });
    assert.equal(await ace._maximumBurn.call(),30E18,"_icoPercent shouldn't have changed")
  });

  it("Investor can approve allowance and spender can transfer tokens from investor", async () =>{
    assert.equal(await ace.allowance.call(investor,investor2), 0);
    await ace.addInvestorList([investor], { from: owner });
    await ace.buyAce({from:investor, value:web3.utils.toWei('1', 'ether')})
    assert.equal((await ace.balanceOf.call(investor)).toString(), "1000000000000000000");
    await ace.turnOnTradable({from:owner});
    await ace.approve(investor2, 500, {from: investor});
    assert.equal(await ace.allowance.call(investor,investor2), 500, "the allowance should be 500");
    await ace.transferFrom(investor, investor2, 500, {from: investor2});
    assert.equal(await ace.allowance.call(investor,investor2),0,"the allowance should be 0")
    assert.equal(await ace.balanceOf.call(investor2), 500,"the investor2 should get 500 tokens")
  });

  describe("Investor purchases Tokens", function() {

    beforeEach(async () => {
      await ace.addInvestorList([investor], { from: owner });
      await ace.buyAce({ from: investor, value: web3.utils.toWei('1', 'ether') });
    });

    it("Investors can't transfer Tokens if Tradable is off", async () => {
      assert.equal(await ace.tradable.call(), false);
      await assertFail(async () => {
        await ace.transfer(investor2, 1, { from: investor });
      });
    });

    it("Investors can transfer Tokens if Tradable is on", async () => {
      await ace.turnOnTradable({ from: owner });
      assert.equal(await ace.tradable.call(), true);
      await ace.transfer(investor2, 100000000, { from: investor });
      assert.equal(await ace.balanceOf.call(investor2), 100000000);
    });
    
  });
});
