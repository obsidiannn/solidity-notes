# 使用geth部署私链


#### 1.下载源码

[go-ethereum](https://github.com/ethereum/go-ethereum/tree/master)
* 注意`v1.12.0` 之后的版本，不再支持私链了 [来源](https://ethereum.stackexchange.com/questions/150714/fatal-failed-to-register-the-ethereum-service-ethash-is-only-supported-as-a-hi)


#### 2.环境准备
  * 准备 golang 1.20.x 的版本
  * 进入 go-ethereum目录，执行：
  ```shell
    make geth
    sudo cp ./build/bin/geth /usr/local/bin/
  ```

#### 3.部署步骤
  * 3.1 确定区块的存储位置，以下假定为`/home/raymooonn/data/coin/geth_data`
  * 3.2 创建初始账号(可创建多次)
    ```shell
      geth --datadir /home/raymooonn/data/coin/geth_data account new
      # 交互输入密码，并得到address 与 privateKey
    ```
      * 验证并得到私钥
    ```go
    package main
    import (
    	"encoding/hex"
    	"fmt"
    	"io/ioutil"
    	"log"
    	"github.com/ethereum/go-ethereum/accounts/keystore"
    	"github.com/ethereum/go-ethereum/crypto"
    )

    func main() {
      //  这里就是keystore生成的私钥文件
    	privKey, address, err := KeystoreToPrivateKey("UTC--2024-02-29T16-49-38.103972826Z--30f1662cd60e496b791c2448e38e7197e95a63dd", "123456")
    	if err != nil {
    		log.Fatal(err)
    	}
    	fmt.Printf("privKey:%s\naddress:%s\n", privKey, address)
    }

    func KeystoreToPrivateKey(privateKeyFile, password string) (string, string, error) {
    	keyjson, err := ioutil.ReadFile(privateKeyFile)
    	if err != nil {
    		fmt.Println("read keyjson file failed：", err)
    	}
    	unlockedKey, err := keystore.DecryptKey(keyjson, password)
    	if err != nil {

    		return "", "", err

    	}
    	privKey := hex.EncodeToString(unlockedKey.PrivateKey.D.Bytes())
    	addr := crypto.PubkeyToAddress(unlockedKey.PrivateKey.PublicKey)
    	return privKey, addr.String(), nil
    }
    ```
  * 3.3 初始化账号余额
    > 如果需要初始化账号余额，就修改[初始化json](./genesis.json)的内容
      ```json
      {
          "alloc": {
    		"0x71d37eEB3ff9B7d58B7D47e679f6C7556acec758": {
    			"balance": "1000000000000000000000000"
    		},
    		"0x30f1662cD60E496B791C2448E38E7197E95A63DD": {
    			"balance": "1000000000000000000000000"
    		}
    	 }
      }
      ```

    * 3.4 初始化创世区块，并进入console

    ```shell
      geth --nodiscover --networkid 5777 --http --http.addr "0.0.0.0" --http.port 7545 --http.api personal,eth,net,web3 --allow-insecure-unlock --datadir /home/raymooonn/data/coin/geth_data console
    ```

    * 3.5 验证初始钱包的金额
    在console内执行
      ```js
          eth.getBalance("0x71d37eEB3ff9B7d58B7D47e679f6C7556acec758");
      ```

    * 3.6 挖矿
    在console执行

      ```js
         miner.setEtherbase("0x30f1662cD60E496B791C2448E38E7197E95A63DD")
  	     miner.start(1)
      ```

    * 3.7 转账验证

    ```typescript
      const privateKey = '有钱的私钥'
      const rpcUrl = 'http://127.0.0.1:7545' // 自己的 RPC 地址
      // 创建一个以太坊 provider
      const provider = new ethers.JsonRpcProvider(rpcUrl)
      const wallet = new ethers.Wallet(privateKey, provider)

      // 构建交易对象
      const transaction: TransactionRequest = {
        from: '0x6E37E893F2E9cD629e0A65Ee5364e96E26f2B0EC',
        to: '0x963a01E21B4195b60ED1537959e87183CD5eb898',
        value: ethers.parseEther('5.0')
      }
      // 发送交易
      const sendTransactionResponse = await wallet.sendTransaction(transaction)
      console.log('Transaction Hash:', sendTransactionResponse.hash)

      // 等待交易被确认
      const receipt = await sendTransactionResponse.wait()
      if (receipt !== null) {
        console.log('Transaction confirmed in block:', receipt.blockNumber)
      }
    })
    ```
