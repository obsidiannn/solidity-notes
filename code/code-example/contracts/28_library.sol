// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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