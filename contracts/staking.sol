// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract LMSStaking {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    bool internal locked;

    address public owner;
    address public lastBuyer;
    uint256 public jackpotTime;

    uint256 public initialStakingTimestamp;
    bool public isStakingTimeStampSet;
    mapping(address => uint) public minimumStakingTime;
    uint256 public jackpotAmount;

    bool public isStakingEnabled;
    uint256 public minimumStakingAmount;

    bool public isRewardEnabled;
    uint256 public apr;
    uint256 public totalRewards;
    uint256 public initialRewardTimeStamp;
    address[] public listOfStakers;

    mapping(address => uint256) public balances;
    mapping (address => uint256) public stakingReward;


    IERC20 public erc20Contract;

    /*
    * TODO : Need to figure out events and emits for all the functions
    */
    // event tokensStaked(address from, uint256 amount);
    // event TokensUnstaked(address to, uint256 amount);

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
    * @dev sets the minimum staking time
    * @param _timePeriodInSeconds - Minimum time period in seconds before unstaking can be done
    */
    // function setStakingTimeStamp(uint256 _timePeriodInSeconds) public onlyOwner {
    //     require(isStakingTimeStampSet == false, "Staking Timestamp has already been set");
    //     isStakingTimeStampSet = true;
    //     initialStakingTimestamp = block.timestamp;
    //     minimumStakingTime = initialStakingTimestamp.add(_timePeriodInSeconds);
    // }

    // /*
    // * @dev this function removes the minimum staking time by setting isStakingTimeStampSet to false
    // */
    // function RemoveStakingTimeStamp() public onlyOwner {
    //     require(isStakingTimeStampSet == true, "Staking TimeStamp has not been set yet, so can not be removed");
    //     isStakingTimeStampSet = false;
    // }

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
        require(isStakingTimeStampSet == true, "Set the staking timestamp first");
        minimumStakingAmount = minAmount;
    }

    /*
    * @dev Allows user to stake particular amount of LMS in the contract and updating their balance
    * @dev 5% jackpot fees is deducted from the staking amount and added to the jackpot amount
    * @dev Setting jackpot timer
    * @dev Checking and adding user in the array listOfStakers if they don't already exist
    * @param token - Address of LMS token
    * @param amount - Amount of LMS tokens
    * TODO : Change JackpotTime to 86400 (1 day)
    */
    function stakeTokens(IERC20 token, uint256 amount) public noReentrant {
        require(isStakingTimeStampSet == true, "Set the staking timestamp first");
        require(token == erc20Contract, "You are only allowed to stake LMS tokens");
        require(amount <= token.balanceOf(msg.sender), "Not enough LMS tokens in your wallet");
        require(isStakingEnabled==true, "Staking hasn't been enabled yet");
        require(amount>=minimumStakingAmount, "Amount entered is less than minimum staking amount");
        if(minimumStakingTime[msg.sender] != 0)
         require(block.timestamp >= minimumStakingTime[msg.sender], "Minimum staking time has not passed yet" );

        
        uint256 fee = amount.mul(5).div(100);
        uint256 actual = amount.mul(95).div(100);

        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = balances[msg.sender].add(actual);
        jackpotAmount = jackpotAmount.add(fee);
        lastBuyer = msg.sender;
        jackpotTime = block.timestamp.add(60);
        minimumStakingTime[msg.sender] = block.timestamp.add(60);

        bool checkIfStakerExist = false;
        for(uint i = 0; i<listOfStakers.length; i++){
            if(listOfStakers[i] == msg.sender) {
                checkIfStakerExist = true;
                break;
            }
        }
        if(checkIfStakerExist == false) listOfStakers.push(msg.sender);

        // emit tokensStaked(msg.sender, actual);
    }

    /*
    * @dev Allows user to unstake particular amount of LMS from the contract and updating their balance
    * @dev Removing the user from the array listOfStakers if they have no more tokens staked
    * @param token - Address of LMS token
    * @param amount - Amount of LMS tokens to be unstaked
    * TODO : Test if delete listOfStakers[i] works
    */
    function unstakeTokens(IERC20 token, uint256 amount) public noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        require(token == erc20Contract, "Token parameter must be LMS token contract address which was passed into the constructor");
        require(block.timestamp >= minimumStakingTime[msg.sender], "Minimum staking time period has not been passed yet");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);
        token.safeTransfer(msg.sender, amount);
        //emit TokensUnstaked(msg.sender, amount);    
        
        if(balances[msg.sender] == 0)
        {
            for(uint i = 0; i<listOfStakers.length; i++)
            {
                if(listOfStakers[i] == msg.sender) {
                    delete listOfStakers[i];
                    break;
                }
            }
        }
    }
    
    /*
    * @dev Transferring the jackpot amount to the winner
    * @param token - Address of LMS token
    */
    function jackpotWinner(IERC20 token) public noReentrant {
        require(block.timestamp >= jackpotTime, "24hrs have not passed since the last staker yet");
        require(jackpotAmount > 0);
        token.safeTransfer(lastBuyer, jackpotAmount);
        jackpotAmount = 0;
    }

/////////////////////////// Functions for Rewards from Staking APR ///////////////////////////

    /*
    * @dev Enables additional rewards on the staked tokens for users
    * @param amount - Amount of LMS tokens
    * @param truefalse - true to enable staking rewards, false to disable staking rewards
    */
    function enableRewards(bool truefalse) public onlyOwner{
        require(isStakingEnabled==true, "Staking hasn't been enabled yet");
        isRewardEnabled = truefalse;
    }

    /*
    * @dev Sets intial timestamp so that rewards can be calculated and added to reward balance only once in a day 
    */
    function setRewardTimestamp() public onlyOwner{
        initialRewardTimeStamp = block.timestamp;
    }
    
    /*
    * @dev Sets the APR for reward tokens
    * @param _apr - Rate at which rewards are distributed
    */
    function setAPR(uint256 _apr) public onlyOwner noReentrant{
        require(_apr > 0, "APR must be greater than 0");
        apr = _apr;
    }

    /*
    * @dev Transfers reward tokens from dev wallet to the contract
    * @param token - Address of LMS token
    * @param _amount - Amount of LMS tokens to be transferred
    */
    function addRewards(IERC20 token, uint256 _amount) public onlyOwner noReentrant{
        token.safeTransferFrom(msg.sender, address(this), _amount);
        totalRewards = totalRewards.add(_amount);
    }

    /*
    * @dev Calculates and updates the amount of rewards for each user
    * TODO : Calling this twice in a day using CRON Jobs to calculate staking rewards of all users
    */
    function caclulateRewards() public noReentrant{
        require(isRewardEnabled==true, "Staking Rewards haven't been enabled yet");
        require(initialRewardTimeStamp != 0, "Please set the staking reward timestamp first");
        require(block.timestamp > initialRewardTimeStamp.add(86400),"24hrs not passed yet since the last reward calculation");
        initialRewardTimeStamp = block.timestamp;
        for(uint i = 0; i<listOfStakers.length; i++)
        {
            stakingReward[listOfStakers[i]] = (balances[listOfStakers[i]].mul(apr).div(365).div(100)).add(stakingReward[listOfStakers[i]]);
        }
    }
    
    /*
    * @dev Withdraws the rewards to the function caller
    * @param token - Address of reward token
    * @param _amount - Amount of reward tokens
    */
    function withdrawRewards(IERC20 token, uint256 _amount) public noReentrant{ 
        require(stakingReward[msg.sender] >= _amount, "Insufficient staked reward balance");
        require(token == erc20Contract, "Token parameter must be LMS token contract address which was passed into the constructor");
        token.safeTransfer(msg.sender, _amount);
        stakingReward[msg.sender] = stakingReward[msg.sender].sub(_amount);
    }


    /*
    * @dev this function will let the owner of the contracct to transfer tokens except LMS out of it
    * @param token - Address of accidentally locked token
    * @param amount - amount of tokens to transfer
    */
    function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        require(token != erc20Contract, "Token address can not be ERC20 address which was passed into the constructor");
        token.safeTransfer(owner, amount);
    }
    
}

/*TO DO -
//look at public views and etc on all functions.
//where to put noReentrant
*/