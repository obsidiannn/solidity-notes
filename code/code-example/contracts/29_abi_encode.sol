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
// abi.encode 将每个数据填充为32字节，中间补0
// abi.encodePacked 省略数据长度的abi.encode
contract AbiEncode {
    function test (address  _contract ,bytes calldata data) external {
         (bool ok ,) = _contract.call(data);
         require(ok,"call error");
    }

    function withSign(address _to,uint amount)external pure returns (bytes memory){
        return abi.encodeWithSignature("transfer(address,uint256)", _to,amount);
    }

    function encodeWithSelector(
        address to,
        uint amount
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    function encodeCall(address to, uint amount) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }

}
// abi encode 不包含信息，所以编解码时需要保持一致
contract AbiDecode{
    struct IStruct {
        string name;
        uint[2] nums;
    }

    
    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        IStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

    function decode(
        bytes calldata data
    ) external pure
        returns (uint x, address addr, uint[] memory arr, IStruct memory myStruct)
    {
        (x, addr, arr, myStruct) = abi.decode(data, (uint, address, uint[], IStruct));
    }
}