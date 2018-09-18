let Ace = artifacts.require("Ace");

const assertFail = require("./helpers/assertFail");
var BN = web3.utils.BN;

contract("Ace", function([owner, investor, investor2, vandal]) {
  let ace;

  beforeEach(async () => {
    ace = await Ace.new();
  });

  it("The owner can turn off the sale", async () => {
    assert.equal(await ace._selling.call(), true);
    await ace.turnOffSale({ from: owner });
    assert.equal(await ace._selling.call(), false, "The sale status should have been updated");
  });

  it("A vandal can't turn off the sale", async () => {
    assert.equal(await ace._selling.call(), true);
    await assertFail(async () => {
      await ace.turnOffSale({ from: vandal });
    })
    assert.equal(await ace._selling.call(), true, "The Sale status should not have changed");
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
  });

  it("Investors can't purchase Ace Tokens if not whitelisted", async () => {
    assert.equal(await ace.balanceOf.call(investor), 0);
    await assertFail(async () => {
      await ace.buyAce({ from: investor, value: web3.utils.toWei('1', 'ether') });
    });
    assert.equal(await ace.balanceOf.call(investor), 0);
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
