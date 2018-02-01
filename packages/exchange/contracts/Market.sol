pragma solidity ^0.4.18;

import { CLLu } from './libs/CLL.sol';
import { ERC20 } from './interfaces/ERC20.sol';

contract Market {
  using CLLu for CLLu.CLL;

  ERC20 public primary;
  ERC20 public secondary;

  uint public lastBid = 0;
  uint public lastAsk = 0;
  uint public bidCount = 0;
  uint public askCount = 0;
  uint public lastTrade = 0;

  struct Order {
    address account;
    uint amount;
    uint price;
  }

  struct Tick {
    uint total;
    Order[] orders;
  }

  event Bid(uint price, uint amount);
  event Ask(uint price, uint amount);

  CLLu.CLL orderList;
  mapping(uint => Tick) public orders;

  mapping(address => Order[]) ordersByAccount;

  function Market(address _primary, address _secondary) public {
    primary = ERC20(_primary);
    secondary = ERC20(_secondary);
  }

  function getTickAmount(uint price) public view returns (uint) {
    return ordersByAccount[msg.sender][price].amount;
  }

  function tickRelations(uint price) public view returns (uint prev, uint next) {
    uint[2] memory node = orderList.getNode(price);
    prev = node[0];
    next = node[1];
  }

  function bid(uint price, uint amount) public {
    Bid(price, amount);
    Order memory order = Order(msg.sender, amount, price);

    // If there's an ask order already, process the order right away
    if (price >= lastAsk && lastAsk > 0) {
      buy(order);
      return;
    }

    Tick storage tick = orders[price];
    tick.total += amount;
    tick.orders.push(order);

    // Insert a CLL reference only if a new tick was created
    if (tick.orders.length == 1) {
      if (price > lastBid) {
        orderList.insert(lastBid, price, true);
      } else {
        uint ref = orderList.seek(lastBid, price, false);
        orderList.insert(ref, price, true);
      }
    }

    // If this is the highest bid, then set the current bid to this
    if (price > lastBid) {
      lastBid = price;
    }
  }

  function ask(uint price, uint amount) public {
    Ask(price, amount);
    Order memory order = Order(msg.sender, amount, price);

    // If there's an bid order already, process the order right away
    if (price <= lastBid && lastBid > 0) {
      sell(order);
      return;
    }

    Tick storage tick = orders[price];
    tick.total += amount;
    tick.orders.push(order);

    // Insert a CLL reference only if a new tick was created
    if (tick.orders.length == 1) {
      if (lastAsk == 0) {
        // Without this check, it creates an infinite loop
        orderList.insert(0, price, true);
      } else if (price < lastAsk) {
        orderList.insert(lastAsk, price, false);
      } else if (price < orderList.step(0, false)) {
        uint ref = orderList.seek(lastAsk, price, true);
        orderList.insert(ref, price, false);
      } else {
        orderList.insert(lastAsk, price, true);
      }
    }

    // If this is the lowest ask, then set the current ask to this
    if (price > lastAsk) {
      lastAsk = price;
    }
  }

  function buy(Order bidOrder) internal {
    uint amount = bidOrder.amount;

    while (amount > 0) {
      Tick memory askOrder = orders[lastAsk];
    }

    lastTrade = bidOrder.price;
    lastBid = lastTrade;
  }

  function sell(Order askOrder) internal {
    lastTrade = askOrder.price;
    lastAsk = lastTrade;
  }
}
