// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/** 
    Erc20 代币
    基础：支持增发
    初始化：自动设置管理员为创建者
    转移：重新设置创建者 
*/
contract RmcErc20 is ERC20,Ownable {
    // 创建者 
    // 设置币种汇率 一个外币需要多少个 rmc
    mapping(address=>uint256) public _supported_token;
    uint256 public _limit;
    /**
    name: 货币名称
    symbol: 代称
    supplyAmount: 首次发行量
    */
    constructor(string memory name,string memory symbol,uint supplyAmount) ERC20(name,symbol) Ownable(msg.sender) {
        _limit = supplyAmount;
    } 

    // 增发
    function increaseLimit(uint amount) public {
        _checkOwner();
        _limit += amount;
    }  

    // 检查是否超出发行上限
    function checkLimit(uint256 count) public view {
        require(_limit >= totalSupply() + count, "token limit need increase");
    }

    // 更新可支付币种+单价
    function updateSupportToken(address tokenAddr,uint256 price) public {
        _checkOwner();
        _supported_token[tokenAddr] = price;
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

    // 兑换币
    function mintToken(address tokenAddr,uint256 buyCount) public payable {
        uint256 totalAmount = checkPrice(tokenAddr,buyCount);
        ERC20 token = ERC20(tokenAddr);
        bool success = token.transferFrom(msg.sender,owner(),totalAmount);
        require(success,"pay error");
        _mint(msg.sender, buyCount);
    }

}