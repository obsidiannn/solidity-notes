## nft  非同质化资产

### 设定

* nft（大多数遵守erc-721标准） 是一种数字资产
  * 比如`无聊猿`头像等等
* 遵守erc-721标准
  * 以太坊的nft: erc721 、erc1155
  * tron nft: trc721
* 以数据形式存储在区块链上并保存在兼容钱包内
* 每个NFT 都有自己特定属性集合，属性集合决定了唯一性
* 以太坊使用钱包`MyEtherWallet`
  * 交易nft使用eth而不是gas，因为nft必须整数交易


### 解析

> erc721代码地址： [v5.0.1 IERC721](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC721/IERC721.sol)

* IERC721 继承了 IERC165
