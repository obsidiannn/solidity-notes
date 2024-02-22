// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ExternalContract { 
    address public owner;

    constructor(address _owner) {
        require(_owner != address(0),"error address ");
        owner = _owner;
    }

    function func(uint x) public pure returns (string memory){
        require(x!=0,"x must != 0");
        return "func called";
    }
}

contract Bar { 
    event Log(string message);
    event LogBytes(bytes data);
    ExternalContract public foo;

    constructor(){
        foo = new ExternalContract(msg.sender);
    }

    function tryCatchExternalCall(uint _x ) public {
        try foo.func(_x) returns (string memory result ){
            emit Log(result);
        } catch {
            emit Log("call failed");
        }

    }
}