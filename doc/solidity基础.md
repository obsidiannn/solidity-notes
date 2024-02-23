## solidity 关键字语义

* immutable： 只可在`constructor` 内定义的，类似java的`final`

* `ether` 与 `wei`的关系
  * 1 `ether` = 10**18 次方的`wei`
  ```solidity
    uint public oneWei = 1 wei;
    // 1 wei is equal to 1
    bool public isOneWei = 1 wei == 1;

    uint public oneEther = 1 ether;
    // 1 ether is equal to 10^18 wei
    bool public isOneEther = 1 ether == 1e18;
  ```
* `gas`
  * 一次事务所话费的ether 数量是：
    * `gas价格` * `gas数量`,并换算成`eth`

* `pure`
  * 修饰在函数上，承诺此函数不会进行事务读写操作，可以用来修饰工具函数
* `view`
  * 修饰在函数式，承诺不写状态，只进行读取

* `mapping`： Map结构
  * 是一个hash的数据结构： ` mapping(keyType => valueType)`

  ```solidity
    mapping(address => uint ) public mapField;
  ```

* Array 数组
  * 不定长：
  ```solidity
    uint [] public arr;
    uint [] public arr2 = [1,2,3];
  ```
  * 定长
  ```solidity
    uint [5] public arr;
  ```

  * [].pop() 删掉末尾元素，并长度减1
  * [].push(x) 增加元素到末尾，长度+1
  * `delete arr[x]` 仅仅重置x下标的元素，数组长度不变

* mapping 不可以用于函数的`输入`或`输出`

#### Error

* 异常抛出，则本次事务会回滚
  * 异常抛出的方式

  ```solidity
    // 1
    require(_i > 0,'error: i must <= 0' );
    // 2
    if( _i > 0){
      revert('error')
    }
    // 3
    assert(_i <= 0)
    // 4 自定义异常
    error CustomError(uint a,uint b);
    if( i > 0){
      revert CustomError({a: 1,b: 2});
    }
  ```


#### 函数修饰符： modifier
  > 类似增强或者是装饰器, java的aop，node的@xxx

  * 用来验证是否具备此函数的执行条件，便于复用

    ```solidity
      modifier onlyOwner(){
        require(owner == msg.sender,"must owner");
      }
      function changOwner(address newOwner) public onlyOwner {
        owner = newOwner;
      }
    ```

#### 事件：Events
* 由合约内部触发的，可以被外部应用监听到的消息
* 由关键字 `emit` 进行发送操作
  ```solidity
    // 定义事件
    event Log(address indexed sender,string message);
    // 发起事件
    emit Log(msg.sender,"say hi");
  ```

* 关于`indexed` 字段
  * 被`indexed` 修饰的字段会被列为topic
  * 一个事件，最大4个topic，且第一个是系统默认的topic事件签名
    * 因此，代码内最多声明`3`个topic
  * topic字段，可以被用来进行筛选，比如可以设置from地址为topic，然后对其进行事件监听
  * 监听可以通过ether 提供的web3库实现

#### 继承
  * solidity 支持多继承
  * 父函数，如果想被子函数重写，需要被`virtual` 声明
  * 子函数，如果想重写父函数，需要被`override`声明
  * 继承后，子合约使用super的函数，遵循就右原则

```solidity
contract X {
  string public name;
  constructor(string memory _name){
    name = _name;
  }
}
// 两种初始化及继承的写法
contract XSon is X("x contract 's son") {

}

contract XSon is X {
  constructor(string memory_name) X(_name) {}
}

```

#### 接口 interface

* 与java类似
* 所有在interface声明的函数，只可以在外部调用（external）
* 不可声明变量与属性
* 实际上他可以去调用其他合约的开放函数

```solidity
// 定义一个接口 ICounter
interface ICounter {
    function count() external view returns (uint);
    function increment() external;
}
// 这是ICounter 的实现合约Counter
// 注意， is ICounter 也可以不写，但必须实现全部函数
contract Counter is ICounter {
    uint public count;
    function increment() external {
        count += 1;
    }
}
/*
  1.首先部署Counter，并获取它的合约地址xxx
  2.再部署MyContract
  3.把Counter的地址传入_counter，就可以找到Counter合约并调用Counter
 */
contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }
    function getCount(address _counter) external view returns (uint) {
        return ICounter(_counter).count();
    }
}
```

#### 可支付 Payable
* 被`payable`修饰的函数、属性、构造器，即可传入金额，给对应合约
* 本合约发送给对应人，也是可以的

  ```solidity
    // 发送给某个人 _to
    function sendMoney(address payable _to, uint _amount) public {
        (bool success,) = _to.call{value: _amount}("");
        require(success,'failed send money');
    }
  ```


#### 合约接受eth

* 合约如果想接受以太币，比如有以下两个方法的至少一个（初始化的时候打进去，不算）
  * receive() external payable
  * fallback() external payable

* 合约发送钱，最好用call，因为安全更高

  ```solidity
  function sendViaCall(address payable _to) public payable {
      // Call returns a boolean value indicating success or failure.
      // This is the current recommended method to use.
      (bool sent, bytes memory data) = _to.call{value: msg.value}("");
      require(sent, "Failed to send Ether");
  }
  ```

#### call 与 delegatecall

* call 功能调用
* delegatecall 逻辑调用


#### 合约内创建新合约

  ```solidity
    Car [] public cars;
    // 普通创建
    function create(address _owner,string memory _model) public {
        Car car = new Car(_owner,_model);
        cars.push(car);
    }
    // 创建并发送eth
    function createAndSendEth(address _owner,string memory _model) public payable  {
        Car car = new Car{value: msg.value}(_owner,_model);
        cars.push(car);
    }
    //  使用create2 创建car，需要携带盐值
    function create2(address _owner,string memory _model,bytes32 _salt) public  {
        Car car = (new Car){salt: _salt} (_owner,_model);
        cars.push(car);
    }
  ```

#### import的方式

* 相对路径引用
  ```solidity
  import {Unauthorized, add as func, Point} from "./Foo.sol";
  ```
* 远端引用
  ```solidity
  import "https://github.com/owner/repo/blob/branch/path/to/Contract.sol";
  ```

#### Library 包
  * Library 类似 Contract,但不可以发送eth，不可以声明变量
  * Library 如果没有对外函数，则会被合并到contract
  * 使用 library 必须部署，并通过连接引用

  ```solidity
  library Math {
      // 求平方
      function square(uint y) internal pure returns (uint z) {
          return y * y;
      }
  }
  contract TestMath {
      function testSquare(uint _y) public pure returns(uint){
          return Math.square(_y);
      }
  }
  ```
#### storge & memory & calldata的使用时机
  * memory:
    * 在函数执行期间，存储那些需要的临时数据
    * 用于函数参数，本地变量，临时的数组
    * 一旦函数执行完毕，内存即释放
  * calldata:
    * 用于存储从`外部调用者`传入的函数参数。
    * `calldata`是只读的，无法变更的
    * 那些不需要存储在内存、链上的，且由外部传入的，可以被定义为calldata
    * 与 memory的区别是： memory 可以被修改，而calldata是只读的
  * storge
    * 用于存放链上的永久数据


#### abi encode
* `abi.encode` 将每个数据填充为32字节，中间补0
* `abi.encodePacked` 省略数据长度的abi.encode
  * 如果不与合约交互，且需要省空间的时候，可以使用
* `abi.encodeWithSignature`:
  * 相比`abi.encode`，增多了一个`函数签名`的参数,放在首位
  * 签名函数 = keccak-sha3(函数名+参数)
* `abi.encodeWithSelector`
  * 相比`abi.encodeWithSignature` ，第一个参数为函数选择器

#### abi 使用场景
  * 通过call实现合约底层调用
  * ethers.js abi 实现合约导入


#### gas 优化
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
