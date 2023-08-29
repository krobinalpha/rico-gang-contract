 // SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "../members/interfaces/ILeader.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTStaking {

    using SafeMath for uint256;

    address public nftContractAddress;
    address public tokenContractAddress;

    uint256 public minimumStakeAmount = 1 ether;
    uint256 public stakingPeriod = 30 days;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        bool claimed;
    }

    mapping (address => mapping(uint256 => Stake)) public stakedNFTs;

    event StakeNFT(address indexed staker, uint256 indexed tokenId, uint256 indexed amount, uint256 startTime, uint256 endTime);
    event UnstakeNFT(address indexed staker, uint256 indexed tokenId, uint256 indexed amount, uint256 reward);
    event WithdrawRewards(address indexed staker, uint256 indexed amount);

    constructor(address _nftContractAddress, address _tokenContractAddress) {
        nftContractAddress = _nftContractAddress;
        tokenContractAddress = _tokenContractAddress;
    }

    function stakeNFT(uint256 _tokenId, uint256 _amount) public {
        require(IERC20(tokenContractAddress).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        require(_amount >= minimumStakeAmount, "Insufficient amount");
        require(ILeader(nftContractAddress).ownerOf(_tokenId) == msg.sender, "Not the owner of NFT");
        require(ILeader(nftContractAddress).getApproved(_tokenId) == address(this), "Approve this contract first");

        Stake memory newStake = Stake({
            amount: _amount,
            startTime: block.timestamp,
            endTime: block.timestamp.add(stakingPeriod),
            claimed: false
        });

        stakedNFTs[msg.sender][_tokenId] = newStake;

        emit StakeNFT(msg.sender, _tokenId, _amount, newStake.startTime, newStake.endTime);
    }

    function unstakeNFT(uint256 _tokenId) public {
        require(stakedNFTs[msg.sender][_tokenId].amount > 0, "No stake found for this NFT");
        require(block.timestamp >= stakedNFTs[msg.sender][_tokenId].endTime, "Staking period not ended yet");

        uint256 reward = calculateReward(msg.sender, _tokenId);

        require(IERC20(tokenContractAddress).transfer(msg.sender, stakedNFTs[msg.sender][_tokenId].amount.add(reward)), "Reward withdrawal failed");

        stakedNFTs[msg.sender][_tokenId].amount = 0;
        stakedNFTs[msg.sender][_tokenId].claimed = true;

        emit UnstakeNFT(msg.sender, _tokenId, stakedNFTs[msg.sender][_tokenId].amount, reward);
    }

    function withdrawRewards(uint256 _amount) public {
        require(_amount > 0, "Invalid amount");

        uint256 totalRewards = calculateRewards(msg.sender);

        require(totalRewards >= _amount, "Insufficient rewards");

        require(IERC20(tokenContractAddress).transfer(msg.sender, _amount), "Reward withdrawal failed");

        emit WithdrawRewards(msg.sender, _amount);
    }

    function calculateReward(address _staker, uint256 _tokenId) internal view returns (uint256) {
        uint256 rewardPercentage = stakedNFTs[_staker][_tokenId].amount.mul(10).div(100);
        uint256 stakingPeriodPercentage = block.timestamp.sub(stakedNFTs[_staker][_tokenId].startTime).mul(100).div(stakingPeriod);
        return stakedNFTs[_staker][_tokenId].amount.mul(rewardPercentage).mul(stakingPeriodPercentage).div(10000);
    }

    function calculateRewards(address _staker) public view returns (uint256) {
        uint256 totalRewards;
        for (uint256 i = 0; i < ILeader(nftContractAddress).balanceOf(_staker); i++) {
            uint256 tokenId = ILeader(nftContractAddress).tokenOfOwnerByIndex(_staker, i);
            if (stakedNFTs[_staker][tokenId].amount > 0 && !stakedNFTs[_staker][tokenId].claimed) {
                totalRewards = totalRewards.add(calculateReward(_staker, tokenId));
            }
        }
        return totalRewards;
    }
}