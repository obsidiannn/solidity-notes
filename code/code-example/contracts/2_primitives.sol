// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract PrimitiveDataType {
    bool public isTrue;
    /*
    uint stands for unsigned integer, meaning non negative integers
    different sizes are available
        uint8   ranges from 0 to 2 ** 8 - 1
        uint16  ranges from 0 to 2 ** 16 - 1
        ...
        uint256 ranges from 0 to 2 ** 256 - 1
    */
    uint256  public u256 = 100000000000000000000000; 
    int8 i8 = 127;
    int16 i16 = -2**15;
    bytes1 b1 = 0xff;
    uint [] public dyArr = [1,2,3];

    uint8 public constant NORMAL = 0;

    function get() public view returns (int8){ 
        return i8;
    }

    function incre(uint val) public {
        dyArr.push(val);
    }

}