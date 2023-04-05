const { network, ethers, deployments } = require("hardhat");
const { assert } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config");
const { moveBlocks } = require("../../utils/move-block");
const { moveTime } = require("../../utils/move-time");

const SECONDS_IN_A_DAY = 86400;
const SECONDS_IN_A_YEAR = 31449600;

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("StakingRewards uint test", function () {
      let deployer, staking, rewardToken, stakeAmount;

      beforeEach(async () => {
        const accounts = await ethers.getSigners();
        deployer = accounts[0];
        await deployments.fixture(["all"]);
        staking = await ethers.getContract("StakingRewards");
        rewardToken = await ethers.getContract("RewardToken");
        stakeAmount = ethers.utils.parseEther("100000");
      });

      describe("constructor", () => {
        it("sets the reward token address correctly", async () => {
          const response = await staking.getRewardsToken();
          assert.equal(response, rewardToken.address);
        });
      });

      describe("rewardsPerToken", () => {
        it("return the reward amount of 1 token based on time spent locked up", async () => {
          await rewardToken.approve(staking.address, stakeAmount);
          await staking.stakeToken(stakeAmount);
          await moveTime(SECONDS_IN_A_DAY);
          await moveBlocks(1);
          let reward = await staking.getRewardsPerToken();
          let expectedReward = "86";
          assert.equal(reward.toString(), expectedReward);

          await moveTime(SECONDS_IN_A_YEAR);
          await moveBlocks(1);

          reward = await staking.getRewardsPerToken();
          expectedReward = "31536";
          assert.equal(reward.toString(), expectedReward);
        });
      });
    });
