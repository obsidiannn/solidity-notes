// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/** 
    Erc20 代币
    基础：支持增发
    初始化：自动设置管理员为创建者
    转移：重新设置创建者 
*/
contract RmcErc20 is ERC20,Ownable {
    // 创建者 
    address private creator;
    // 设置币种汇率
    mapping(address=>uint256) public _supported_token;

    /**
    name: 货币名称
    symbol: 代称
    totalAmount: 总发行数量
    */
    constructor(string memory name,string memory symbol,uint totalAmount,) ERC20(name,symbol) {
        creator = msg.sender; 
        _mint(msg.sender,totalAmount * (10 ** decimals()) );
    } 

    // 增发
    function mintMore(uint amount) public {
        require(msg.sender == creator,"not creator");
        _mint(msg.sender,amount * (10 ** decimals()) );
    }  
 
    // 销毁
    function burnToken(uint amount) public {
        _burn(msg.sender,amount);
    }

    // 转移所有者
    function changeManager(address newOwner) public {
        require(msg.sender == creator,"not creator");
        require(newOwner != address(0),"Invalid Address");
        creator = newOwner;
    }

    // 更新可支付币种+单价
    function updateSupportToken(address tokenAddr,uint256 price) public {
        _checkOwner();
        _supported_token[tokenAddr] = price;
    }

}