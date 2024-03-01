// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/utils/introspection/ERC165.sol";

interface IERC721 is IERC165 {
    // 某人的余额
    function balanceOf(address owner) external view returns (uint balance);
    // 某个币的所有者
    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}
contract RaymooonnNFT is ERC721 {

    constructor(string memory name_, string memory symbol_) ERC721(name_,symbol_) {
       
    }
    
    function mint(address to,uint id) external {
        _mint(to,id);
    }

    function burn(uint id) external  {
        require(msg.sender == _ownerOf(id), "not owner");
        _burn(id);
    }
}
