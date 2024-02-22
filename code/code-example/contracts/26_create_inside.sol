// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Car {
    address public owner;
    string public model;
    address public carAddr;

    constructor (address  _owner,string memory _model) payable {
        owner = _owner;
        _model = _model;
        carAddr = address(this);
    }

}

contract CarFactory { 
    Car [] public cars;
    // 普通创建
    function create(address _owner,string memory _model) public {
        Car car = new Car(_owner,_model);
        cars.push(car);
    }
    // 创建并发送eth 
    function createAndSendEth(address _owner,string memory _model) public payable  {
        Car car = new Car{value: msg.value}(_owner,_model);
        cars.push(car);
    }
    //  使用create2 创建car，需要携带盐值
    function create2(address _owner,string memory _model,bytes32 _salt) public  {
        Car car = (new Car){salt: _salt} (_owner,_model);
        cars.push(car);
    }
    
    function getCar(uint _index) public view returns (address owner,string memory model,address carAddr,uint balance ){
        Car car = cars[_index];
        return (car.owner(),car.model(),car.carAddr(),address(car).balance);
    }

}