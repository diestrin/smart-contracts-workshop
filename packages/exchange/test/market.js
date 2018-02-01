const Token = artifacts.require('Token');
const Market = artifacts.require('Market');

contract('Market', accounts => {
  let market, tkn1, tkn2;

  beforeEach(async () => {
    tkn1 = await Token.new();
    tkn2 = await Token.new();
    market = await Market.new(tkn1.address, tkn2.address);
  })

  describe('basic info', () => {
    it('should have 2 tokens', async () => {
      assert.strictEqual(tkn1.address, await market.primary());
      assert.strictEqual(tkn2.address, await market.secondary());
    });
  });

  describe('bid orders', () => {
    const price = 1000;
    const amount = 10;

    beforeEach(async () => {
      await market.bid(price, amount);
    });

    it('should fire the Bid event', async () => {
      const res = await market.bid(price, amount);
      const log = res.logs.find(log => log.event.match('Bid'));
      assert.strictEqual(price, log.args.price.toNumber());
      assert.strictEqual(amount, log.args.amount.toNumber());
    });

    it('should be able to navigate through orders', async () => {
      const prices = [100, 200, 300, 400, 500];

      await Promise.all(prices.map(p => market.bid(p, amount)));

      assert.strictEqual(100, await market.tickRelations(0).then(([p, n]) => n.toNumber()));
      assert.strictEqual(200, await market.tickRelations(100).then(([p, n]) => n.toNumber()));
      assert.strictEqual(300, await market.tickRelations(200).then(([p, n]) => n.toNumber()));
      assert.strictEqual(400, await market.tickRelations(300).then(([p, n]) => n.toNumber()));
      assert.strictEqual(500, await market.tickRelations(400).then(([p, n]) => n.toNumber()));
    });
  });

  describe('ask orders', () => {
    const price = 1000;
    const amount = 10;

    beforeEach(async () => {
      await market.ask(price, amount);
    });

    it('should fire the Ask event', async () => {
      const res = await market.ask(price, amount);
      const log = res.logs.find(log => log.event.match('Ask'));
      assert.strictEqual(price, log.args.price.toNumber());
      assert.strictEqual(amount, log.args.amount.toNumber());
    });

    it.only('should be able to navigate through orders', async () => {
      const prices = [1100, 1200, 1300, 1400, 1500];

      await Promise.all(prices.map(p => market.ask(p, amount)));

      assert.strictEqual(1500, await market.tickRelations(0).then(([p, n]) => p.toNumber()));
      assert.strictEqual(1400, await market.tickRelations(1500).then(([p, n]) => p.toNumber()));
      assert.strictEqual(1300, await market.tickRelations(1400).then(([p, n]) => p.toNumber()));
      assert.strictEqual(1200, await market.tickRelations(1300).then(([p, n]) => p.toNumber()));
      assert.strictEqual(1100, await market.tickRelations(1200).then(([p, n]) => p.toNumber()));
    });
  });
});
