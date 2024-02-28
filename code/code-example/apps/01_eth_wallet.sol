
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//  模拟一个eth 签宝
contract EthWallet {
    address payable owner;
    constructor  () payable {
        owner = payable (msg.sender);
    }

    // 收款
    receive() external payable { }

    // 取款
    function withdraw(uint _amount) external{
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
    }

    // 这个合约剩余的余额
    function getBalance()external view returns(uint){
        return address(this).balance;
    }

// 转账
    function transfer(address _to,uint _amount) external  {
        require(msg.sender == owner, "caller is not owner");
        require(address(this).balance >= _amount,"balance not enough");
        payable(_to).transfer(_amount);

    }

}