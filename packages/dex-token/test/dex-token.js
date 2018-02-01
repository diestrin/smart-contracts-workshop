const DexToken = artifacts.require('DexToken');

contract('DexToken', accounts => {
  let DEX;

  beforeEach(async () => {
    DEX = await DexToken.new();
  });

  describe('basic info', () => {
    it('should have a name', async () => {
      assert.strictEqual('DexToken', await DEX.name());
    });

    it('should have a symbol', async () => {
      assert.strictEqual('DEX', await DEX.symbol());
    });

    it('should have the number of decimal points', async () => {
      assert.strictEqual(8, await DEX.decimals().then(n => n.toNumber()));
    });

    it('should have the total supply number, 20 millions + 8 decimals', async () => {
      assert.strictEqual(20 * 10 ** 14, await DEX.totalSupply().then(n => n.toNumber()));
    });
  });
});
