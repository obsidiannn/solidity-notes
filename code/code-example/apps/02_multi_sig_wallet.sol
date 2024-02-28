// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 多人批准交易钱包
contract MultiSigWallet{
    event Deposit();
    event SubmitTransaction();
    event ConfirmTransaction();
    event RevokeConfirmation();
    event ExecuteTransaction();

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmation;
    }

}