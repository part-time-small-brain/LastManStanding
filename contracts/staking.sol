// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract LMSStaking {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address owner;
    bool internal locked;
    bool public isStakingEnabled;
    bool public isRewardEnabled;
    address public lastStaker;
    uint256 public minimumStakingAmount;
    uint256 public jackpotAmount;
    uint256 public jackpotTime;
    uint256 public apr;
    uint256 public totalRewards;
    uint256 public initialRewardTimeStamp;
    address[] public listOfStakers;

    mapping(address => uint256) public balances;
    mapping(address => uint) public minimumStakingTime;
    mapping(address => uint256) public stakingReward;

    IERC20 public erc20Contract;

    /*
    * @dev Setting new owner and saving LMS contract address
    * @param erc20TokenAddress - Address of LMS token 
    */
    constructor(IERC20 erc20TokenAddress) {
        owner = msg.sender;
        require(address(erc20TokenAddress) != address(0), "erc20TokenAddress address can not be zero");
        erc20Contract = erc20TokenAddress;
        locked = false;
    }

    /*
    * @dev Modifier to prevent reentracy attacks
    */
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /*
    * @dev Modifier to allow only the owner to call the function
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "msg.sender must be the contract owner");
        _;
    }

/////////////////////////// Functions for Staking, Unstaking and Jackpot of LMS ///////////////////////////
    
    /*
    * @dev This function is used to enable staking
    * @param truefalse - true to enable staking, false to disable staking
    */
    function enableStaking(bool truefalse) public onlyOwner {
        isStakingEnabled = truefalse;
    }

    /*
    * @dev This function is used to set the minimum staking amount
    * @param minAmount - minimum amount to stake
    */
    function minStakingAmount(uint256 minAmount) public onlyOwner {
        minimumStakingAmount = minAmount;
    }

    /*
    * @dev Allows user to stake particular amount of LMS in the contract and updating their balance
    * 5% jackpot fees is deducted from the staking amount and added to the jackpot amount
    * Setting jackpot timer
    * Checking and adding user in the array listOfStakers if they don't already exist
    * @param token - Address of LMS token
    * @param amount - Amount of LMS tokens
    */
    function stakeTokens(IERC20 token, uint256 amount) public noReentrant {
        require(token == erc20Contract, "You are only allowed to stake LMS tokens");
        require(amount <= token.balanceOf(msg.sender), "Not enough LMS tokens in your wallet");
        require(isStakingEnabled == true, "Staking hasn't been enabled yet");
        require(amount >= minimumStakingAmount, "Amount entered is less than minimum staking amount");
        if(minimumStakingTime[msg.sender] != 0)
            require(block.timestamp >= minimumStakingTime[msg.sender], "Minimum staking time has not passed yet" );

        uint256 fee = amount.mul(5).div(100);
        uint256 actual = amount.mul(95).div(100);
        bool checkIfStakerExist = false;

        balances[msg.sender] = balances[msg.sender].add(actual);
        jackpotAmount = jackpotAmount.add(fee);
        lastStaker = msg.sender;
        jackpotTime = block.timestamp.add(86400);
        minimumStakingTime[msg.sender] = block.timestamp.add(86400);

        for(uint i = 0; i<listOfStakers.length; i++) {
            if(listOfStakers[i] == msg.sender) {
                checkIfStakerExist = true;
                break;
            }
        }

        if(checkIfStakerExist == false) 
            listOfStakers.push(msg.sender);

        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    /*
    * @dev Allows user to unstake particular amount of LMS from the contract and updating their balance
    * Removing the user from the array listOfStakers if they have no more tokens staked
    * @param token - Address of LMS token
    * @param amount - Amount of LMS tokens to be unstaked
    */
    function unstakeTokens(IERC20 token, uint256 amount) public noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        require(token == erc20Contract, "Token parameter must be LMS token contract address which was passed into the constructor");
        require(block.timestamp >= minimumStakingTime[msg.sender], "Minimum staking time period has not been passed yet");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);      

        if(balances[msg.sender] == 0) {
            for(uint i = 0; i<listOfStakers.length; i++) {
                if(listOfStakers[i] == msg.sender) {
                    listOfStakers[i] = listOfStakers[listOfStakers.length - 1];
                    listOfStakers.pop();
                    break;
                }
            }
        }

        token.safeTransfer(msg.sender, amount);
    }
    
    /*
    * @dev Transferring the jackpot amount to the winner
    * @param token - Address of LMS token
    * TODO : Call this function using a CRON job every 24hrs
    */
    function jackpotWinner(IERC20 token) public noReentrant {
        require(block.timestamp >= jackpotTime, "24hrs have not passed since the last staker yet");
        require(token == erc20Contract, "Token parameter must be LMS token contract address which was passed into the constructor");
        require(jackpotAmount > 0, "Jackpot amount must be greater than 0");
        token.safeTransfer(lastStaker, jackpotAmount);
        jackpotAmount = 0;

    }

/////////////////////////// Functions for Rewards from Staking APR ///////////////////////////

    /*
    * @dev Enables additional rewards on the staked tokens for users
    * @param amount - Amount of LMS tokens
    * @param truefalse - true to enable staking rewards, false to disable staking rewards
    */
    function enableRewards(bool truefalse) public onlyOwner {
        require(isStakingEnabled == true, "Staking hasn't been enabled yet");
        isRewardEnabled = truefalse;
    }

    /*
    * @dev Sets intial timestamp so that rewards can be calculated and added to reward balance only once in a day 
    */
    function setRewardTimestamp() public onlyOwner {
        initialRewardTimeStamp = block.timestamp;
    }
    
    /*
    * @dev Sets the APR for reward tokens
    * @param _apr - Rate at which rewards are distributed
    */
    function setAPR(uint256 _apr) public onlyOwner {
        require(_apr > 0, "APR must be greater than 0");
        apr = _apr;
    }

    /*
    * @dev Transfers reward tokens from dev wallet to the contract
    * @param token - Address of LMS token
    * @param _amount - Amount of LMS tokens to be transferred
    */
    function addRewards(IERC20 token, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Rewards must be more than 0");
        totalRewards = totalRewards.add(_amount);
        token.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /*
    * @dev Calculates and updates the amount of rewards for each user
    * TODO : Calling this twice in a day using CRON Jobs to calculate staking rewards of all users
    * TODO : Disable rewards all together if after calling this function, the total reward balance in contract is less than the payout amount
    */
    function caclulateRewards() public noReentrant {
        require(isRewardEnabled == true, "Staking Rewards haven't been enabled yet");
        require(initialRewardTimeStamp != 0, "Please set the staking reward timestamp first");
        require(block.timestamp > initialRewardTimeStamp.add(86400),"24hrs not passed yet since the last reward calculation");
        initialRewardTimeStamp = block.timestamp;
        
        for(uint i = 0; i<listOfStakers.length; i++) {
            stakingReward[listOfStakers[i]] = (balances[listOfStakers[i]].mul(apr).div(365).div(100)).add(stakingReward[listOfStakers[i]]);
            totalRewards = totalRewards.sub(stakingReward[listOfStakers[i]]);
        }
    }

    /*
    * @dev Compounds the rewards earned by the user, by removing it from rewards and adding it to the staked amount
    */
    function compoundRewards() public noReentrant {
        require(isRewardEnabled == true, "Staking Rewards haven't been enabled yet");
        require(stakingReward[msg.sender] > 0,"Rewards must be greater than zero to compound");
        balances[msg.sender] = balances[msg.sender].add(stakingReward[msg.sender]);
        stakingReward[msg.sender] = 0;
    }
    
    /*
    * @dev Withdraws the rewards to the function caller
    * @param token - Address of reward token
    */
    function withdrawRewards(IERC20 token) public noReentrant {
        require(token == erc20Contract, "Token parameter must be LMS token contract address which was passed into the constructor");
        token.safeTransfer(msg.sender, stakingReward[msg.sender]);
        stakingReward[msg.sender] = 0;
    }

    /*
    * @dev this function will let the owner of the contracct to transfer tokens except LMS out of it
    * @param token - Address of accidentally locked token
    * @param amount - amount of tokens to transfer
    */
    function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlyOwner {
        require(address(token) != address(0), "Token address can not be zero");
        require(token != erc20Contract, "Token address can not be ERC20 address which was passed into the constructor");
        token.safeTransfer(owner, amount);
    }
}

/*
* TODO : Need to figure out events and emits for all the functions
*/
// 100000000000000000000000 = 100000 LMS