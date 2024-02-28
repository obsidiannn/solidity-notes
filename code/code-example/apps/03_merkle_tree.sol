// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MerkleProof {
    function verify () public pure returns (bool){

    }
}

// 默克尔树，两个树root一致则全部一致
contract TestMerkleProof is MerkleProof {
    
    bytes32[]public hashes;
    // 构建树 ，二叉
    constructor () {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];
        for (uint i = 0;i< transactions.length;){
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
            ++i;
        }
        uint n = transactions.length;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        // 这里我感觉有点问题
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

}