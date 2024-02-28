// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/IERC20.sol";

contract RaymooonnToken is ERC20 {
    constructor(string memory name,string memory symbol) ERC20 (name,symbol){
        _mint(msg.sender, 100*10**uint(decimals()));
    }
}

contract TokenSwap{
    // 异种货币兑换 （必须是实现了erc20的）
    
    IERC20 public token1;
    address public owner1;
    uint public amount1;

    IERC20 public token2;
    address public owner2;
    uint public amount2;
    
    /**
    赋值构造器
    其中 _amount1 个_token1 币 = _amount2 个 _token2 币 被 _owner1 与 _owner2 所接受
    **/
    constructor(
        address _token1,
        address _owner1,
        uint _amount1,
        address _token2,
        address _owner2,
        uint _amount2
    ){
        token1 = IERC20(_token1);
        owner1 = _owner1;
        amount1 = _amount1;
        token2 = IERC20(_token2);
        owner2 = _owner2;
        amount2 = _amount2;
    }
    // 转换
    function swap() public {
        // 操作人必须是所有者之一，才可以调用swap
        require(msg.sender == owner1 || msg.sender == owner2,"Authorized error");
        // 校验 owner1 给 此合约的配额是否 >= amount1
        require(token1.allowance(owner1, address(this)) >= amount1, "token1 allowance too low");
        require(token2.allowance(owner2, address(this)) >= amount2, "token2 allowance too low");
        _safeTransferFrom(token1,owner1,owner2,amount1);
    }

    // 转账
    function _safeTransferFrom(IERC20 token,address sender,address to,uint amount ) private {
        bool success = token.transferFrom(sender,to,amount);
        require(success,"transfer error");
    }

}