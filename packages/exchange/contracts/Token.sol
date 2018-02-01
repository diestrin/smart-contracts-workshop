pragma solidity ^0.4.18;

import { ERC20 } from './interfaces/ERC20.sol';
import { SafeMath } from './libs/SafeMath.sol';

contract Token is ERC20 {
  using SafeMath for uint256;

  string public name = "Token";
  string public symbol = "TKN";
  uint256 public decimals = 8;
  uint256 public totalSupply = 100000000000000;

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowed;

  function Token() public {
    balances[msg.sender] = totalSupply;
    Transfer(0x0, msg.sender, totalSupply);
  }

  function balanceOf(address who) public view returns (uint256) {
    return balances[who];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    assert(balances[msg.sender] >= value);

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);

    Transfer(msg.sender, to, value);

    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    allowed[msg.sender][spender] = value;

    Approval(msg.sender, spender, value);

    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return allowed[owner][spender];
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    uint256 _allowance = allowed[from][msg.sender];

    assert(_allowance >= value);
    assert(balances[from] >= value);

    allowed[from][msg.sender] = _allowance.sub(value);
    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);

    Transfer(msg.sender, to, value);

    return true;
  }
}
