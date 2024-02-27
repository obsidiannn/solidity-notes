## solidity gas 相关
> https://github.com/inoutcode/ethereum_book/blob/master/%E7%AC%AC%E5%85%AB%E7%AB%A0.asciidoc#gas

#### 设定

* `gas`
  * 一次事务所话费的ether 数量是：
    * `gas价格` * `gas数量`,并换算成`eth`
* `gasLeft()`: 获取合约内的gas剩余

* block.gaslimit 当前块的gas 限制
* `tx.gasprice`:发起调用的交易中的gas价格。
* gas：发起方支付eth转为gas，然后转为eth发给矿工
* gastoken:在gas低时存储gas，高时使用
  * https://gastoken.io/
#### gas 超出的后果
  * out of gas 异常
  * 合约状态被恢复，事务被回滚
  * 全部gas作为交易费用支付给矿工

#### 能省gas的操作
  * 尽量使用定长数组
  * 避免调用其他未知的合约
  * 使用`web3`包估算gas成本
    ```ts
    var contract = web3.eth.contract(abi).at(address);
    // 需要执行的gas数量
    var gasEstimate = contract.myAweSomeMethod.estimateGas(arg1, arg2, {from: account});
    // ----
    // 获取网络的gas价格
    var gasPrice = web3.eth.getGasPrice();
    // 估算gas
    var gasCostInEther = web3.fromWei((gasEstimate * gasPrice), 'ether');
    ```
  * 更多使用calldata而不是memory
  * 变量加载到内存
  * 循环使用`++i`而不是`i++`
  * 缓存数组
  * 使用短路运算
  * 如果你确定数值不会溢出，可以使用 `unchecked`代码块包裹
  * delete 回收storage
  * 使用library
  * 多用`internal`,`external` 而不是`public`
  * 尽量使用自定义error，提示消息尽量少
  * 使用固定长度的变量，并且把相同长度的变量尽量声明在一起，这样编译器会进行优化
  * gas 退款：删除存储跟删除合约都可以获得gas
