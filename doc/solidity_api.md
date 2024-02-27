## solidity api


### 地址

* address.balance 地址的余额
  * address(this).balance

* address.transfer 转账到某个地址,抛异常
* address.send(amount) 转账到某个地址

### 内置函数

* ecrecover: 从签名中恢复用于签署消息的地址。
* addmod, mulmod
