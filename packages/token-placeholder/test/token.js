const Token = artifacts.require('Token');

contract('Token', accounts => {
  let TKN;

  beforeEach(async () => {
    TKN = await Token.new();
  });

  describe('basic info', () => {
    it('should have a name', async () => {
      assert.strictEqual('DexToken', await TKN.name());
    });

    it('should have a symbol', async () => {
      assert.strictEqual('DEX', await TKN.symbol());
    });

    it('should have the number of decimal points', async () => {
      assert.strictEqual(8, await TKN.decimals().then(n => n.toNumber()));
    });

    it('should have the total supply number, 20 millions + 8 decimals', async () => {
      assert.strictEqual(20 * 10 ** 14, await TKN.totalSupply().then(n => n.toNumber()));
    });
  });
});
