// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RmcNFT is ERC1155,Ownable {
    uint public _limit; 
    uint256 public  _current_token_id = 0;
    // 支付目标账户
    address public _payment_account;
    // 支持的支付合约及对应价格
    mapping(address tokenId => uint256) public _supported_token;

    string public _name;
    string public _symbol;

     /**
    name: 货币名称
    symbol: 代称
    baseURI: 基础url
    supports_token: 可支付币种+单价
    token_price：该token的单价
    limit: 总发行数量
    */
    constructor(
        string memory name,
        string memory symbol, 
        string memory baseURI,
        address pay_account,
        address supports_token,
        uint256 token_price,
        uint256 limit
        ) ERC1155 (baseURI) Ownable(msg.sender){
        _name = name;
        _symbol = symbol;
        setBaseURI(baseURI);
        _limit = limit;
        // 更新可支付币种+单价
        _supported_token[supports_token] = token_price;
        _payment_account = pay_account;
    }

    function setPaymentAccount(address pay_account) public {
        _checkOwner();
        _payment_account = pay_account;
    }

    // 设置地址
    function setBaseURI(string memory uri) public {
        _checkOwner();
        _setURI(uri);
    }

    // 提高发布上限
    function upgradeLimit(uint _count) public {
        _checkOwner();
        _limit += _count;
    }

    // 更新可支付币种+单价
    function updateSupportToken(address tokenAddr,uint256 price) public {
        _checkOwner();
        _supported_token[tokenAddr] = price;
    }
    
    function getNextTokenId(uint256 count) internal returns (uint256[] memory) {
         uint256[] memory result = new uint256[](count);
         for (uint current = 0; current < count; current++) 
         {
            result[current] = _current_token_id + current + 1;
         }
         _current_token_id += count;
         return result;
    }

    // 检查是否超出发行上限
    function checkLimit(uint256 count) public view {
        require(_limit >= _current_token_id + count, "token id need relimit.");
    }

    function checkPrice(address payToken,uint count) view public returns (uint256) {
        uint256 price = _supported_token[payToken];
        require(price > 0,"unsupport token for pay");
        (bool success,uint256 totalAmount) = Math.tryDiv(count,price);
        require(success,"check price error");
        ERC20 token = ERC20(payToken);
        require(token.balanceOf(msg.sender) >= totalAmount,"not enough token");
        require(token.allowance(msg.sender,address(this)) >= totalAmount,"not enough allowance");
        return totalAmount;
    }
    
    // 购买
    function mintNFTs(uint count,address tokenForPay) public payable {
        checkLimit(count);
        uint256 totalAmount = checkPrice(tokenForPay,count);
        ERC20 token = ERC20(tokenForPay);
        bool success = token.transferFrom(msg.sender,_payment_account,totalAmount);
        require(success,"pay error");

        uint256[] memory tokenIds = getNextTokenId(count);
        for (uint i=0; i<tokenIds.length; i++) 
        {   
            _mint(msg.sender, tokenIds[i],1,"");
        }
    }

    
    // 销毁
    function burnToken(uint tokenId) public {
        _burn(msg.sender,tokenId,1);
    }

    // 给合约分配nft
    function mintForContract(uint count,address addr) public {
        _checkOwner();
        uint256[] memory tokenIds = getNextTokenId(count);
        uint [] memory vals = new uint[](count);

        for (uint i=0; i<tokenIds.length; i++) 
        {   
            vals[i] = 1;
        }
        _mintBatch(addr,tokenIds,vals,"");
    }

}