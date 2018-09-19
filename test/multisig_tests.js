let Multisig = artifacts.require("MultiSigWallet");

contract("Multisig", function([owner, owner2, owner3, vandal]) {
  let multisig;

  beforeEach(async () => {
    multisig = await Multisig.new([owner, owner2, owner3], 2, { from: owner, gas: 6000000 });
  });

  it("Can create Ace contract through multisig", async () => {
    await multisig.submitTransaction(multisig.address, 0, "0x3d03ec29", { from: owner });
    await multisig.confirmTransaction(0, { from: owner2, gas: 6000000 });
    let events = await multisig.getPastEvents('CoinCreation');
    assert.equal(events.length, 1);
  });
});
