### ERC20


#### 设定
* 任何遵守erc20标准的合约就是erc20 币
* 原生币如果想变成erc20，需要进行包装(wrap)
* 需要实现功能：
  * 转账
  * 允许其他人代理转账(allow others to transfer token on behalf of the token holder)

  ---
* ERC20的 interface
  ```solidity
  // SPDX-License-Identifier: MIT
  pragma solidity ^0.8.20;

  // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
  interface IERC20 {
      function totalSupply() external view returns (uint);

      function balanceOf(address account) external view returns (uint);

      function transfer(address recipient, uint amount) external returns (bool);

      function allowance(address owner, address spender) external view returns (uint);

      function approve(address spender, uint amount) external returns (bool);

      function transferFrom(
          address sender,
          address recipient,
          uint amount
      ) external returns (bool);

      event Transfer(address indexed from, address indexed to, uint value);
      event Approval(address indexed owner, address indexed spender, uint value);
  }

  ```

#### 异种货币兑换

##### 前置条件

* A 拥有的 a coin , B 拥有的b coin 都是erc20规则的币
* A 与 B 都同意 10 a coin 置换 20 b coin 的条件
* A 或者 B 部署了erc20置换的合约
* A 批准合约提取10 a coin
* B 批准合约提取 20 b coin
* A 或 B 调取 合约的swap 函数
* 本质上，是在一个事务内的两笔完全没关联的操作
  * 我单方面转给你美金，你单方面转给我人民币
  * 只不过通过这个合约充当第三方，且是公开透明的
* end

[code](../code/code-example/apps/04_erc20_custom.sol)
