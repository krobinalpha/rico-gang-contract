//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Leader is ERC721{
    mapping(uint256=> uint8) level;
    mapping(address=>uint256) tokenCount;
    mapping(address=> mapping(uint256=>uint256)) public ownedTokens;
    mapping(uint256=>uint256) tokenIdToIndex;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner), "Owner does not have enough tokens");
        return ownedTokens[_owner][_index];
    }

    function mint(address _to, uint256 _tokenId) external {
        _safeMint(_to, _tokenId);
        tokenCount[_to]+=1;
        ownedTokens[_to][tokenCount[_to]] = _tokenId;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        _safeTransfer(_from, _to, _tokenId, "");
        tokenCount[_from]-=1;
        tokenCount[_to]+=1;
        ownedTokens[_to][tokenCount[_to]] = _tokenId;
    }
}
