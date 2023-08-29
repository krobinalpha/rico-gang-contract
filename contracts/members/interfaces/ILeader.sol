//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILeader is IERC721{
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}