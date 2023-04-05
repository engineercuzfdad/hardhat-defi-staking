// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/* Custom Errors  */

error StakingRewards__TransactionFailed();
error StakingRewards__NeedMoreThanZero();

contract StakingRewards is ReentrancyGuard {
    /* State variables */

    IERC20 private s_stakingToken;
    IERC20 private s_rewardsToken;

    uint256 private constant REWARD_RATE = 100;
    uint256 private s_lastUpdateTime;
    uint256 private s_rewardPerTokenStored;

    uint256 private s_totalSupply;
    mapping(address => uint256) private s_balances;
    mapping(address => uint256) private s_rewards;
    mapping(address => uint256) private s_userRewardPerTokenPaid;

    // events
    event staked(address indexed user, uint256 indexed amount);
    event withdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amounnt);

    /////////////////////
    /// Modifiers ///////
    /////////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert StakingRewards__NeedMoreThanZero();
        }
        _;
    }

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    /////////////////////
    // Main function/////
    /////////////////////

    constructor(address stakingToken, address rewardsToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardsToken = IERC20(rewardsToken);
    }

    function stakeToken(
        uint256 amount
    ) external moreThanZero(amount) nonReentrant {
        s_totalSupply += amount;
        s_balances[msg.sender] += amount;
        emit staked(msg.sender, amount);
        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert StakingRewards__TransactionFailed();
        }
    }

    function withdrawToken(uint256 amount) external nonReentrant {
        s_totalSupply -= amount;
        s_balances[msg.sender] -= amount;
        emit withdrewStake(msg.sender, amount);
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert StakingRewards__TransactionFailed();
        }
    }

    function rewardPerToken() private view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) /
                s_totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((s_balances[account] *
                (rewardPerToken() - s_userRewardPerTokenPaid[account])) /
                1e18) + s_rewards[account];
    }

    function claimRewards() external nonReentrant {
        uint256 reward = s_rewards[msg.sender];
        s_rewards[msg.sender] = 0;
        emit RewardsClaimed(msg.sender, reward);
        bool success = s_rewardsToken.transfer(msg.sender, reward);
        if (!success) {
            revert StakingRewards__TransactionFailed();
        }
    }

    /////////////////////////
    // Getter Function /////
    ////////////////////////

    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }

    function getRewardsToken() public view returns (IERC20) {
        return s_rewardsToken;
    }

    function getRewardsPerToken() public view returns (uint256) {
        return s_rewardPerTokenStored;
    }
}
