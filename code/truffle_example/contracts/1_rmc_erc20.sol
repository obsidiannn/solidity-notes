// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RmcErc20 is ERC20 {
    // 创建者 
    // address private creator;

    constructor(string memory name,string memory symbol,uint totalAmount) ERC20(name,symbol) {
        // creator = msg.sender; 
        _mint(msg.sender,totalAmount * (10 ** decimals()) );
    } 

    // 增发
    function mintMore(uint amount) public {
        // require(msg.sender == creator,"not creator");
        _mint(msg.sender,amount * (10 ** decimals()) );
    }  
 
    // 销毁
    function burnToken(uint amount) public {
        _burn(msg.sender,amount);
    }
}