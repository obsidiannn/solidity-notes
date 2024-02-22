// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address , uint) external ;
}
contract Token is IERC20 {
    function transfer(address , uint) external {
    }
}
// abi encode 是一种合约之间的编码
contract AbiEncode {
    function test (address _contract )
}