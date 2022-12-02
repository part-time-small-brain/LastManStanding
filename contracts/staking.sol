// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract LMSStaking {

    bool internal locked;

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public owner;
    address public lastBuyer;
    uint256 public jackpotTime;

    uint256 public initialTimestamp;
    bool public timestampSet;
    uint256 public timePeriod;
    uint256 public jackpotAmount;

    bool public isStakingEnabled;
    uint256 public minimumStakingAmount;

    uint256 public apr;
    uint256 public totalRewards;
    uint256 public initialRewardTimeStamp;

    mapping(address => uint256) public alreadyWithdrawn;
    mapping(address => uint256) public balances;
    mapping (address => uint256) public stakingReward;


    IERC20 public erc20Contract;

    event tokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);

    constructor(IERC20 erc20TokenAddress) {
        owner = msg.sender;
        timestampSet = false;
        require(address(erc20TokenAddress) != address(0), "erc20TokenAddress address can not be zero");
        erc20Contract = erc20TokenAddress;
        locked = false;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Message sender must be the contract's owner.");
        _;
    }

    modifier timestampNotSet() {
        require(timestampSet == false, "The time stamp has already been set.");
        _;
    }

    modifier timestampIsSet() {
        require(timestampSet == true, "Please set the time stamp first, then try again.");
        _;
    }

    modifier jackpotTimePassed() {
        require(block.timestamp >= jackpotTime, "Jacpot Time has not been passed yet.");
        _;
    }

    function setTimestamp(uint256 _timePeriodInSeconds) public onlyOwner timestampNotSet  {
        timestampSet = true;
        initialTimestamp = block.timestamp;
        timePeriod = initialTimestamp.add(_timePeriodInSeconds);
    }

    function enableStaking(bool truefalse) public onlyOwner {
        isStakingEnabled = truefalse;
    }

    function minStakingAmount(uint256 minAmount) public timestampIsSet onlyOwner {
        require(isStakingEnabled==true, "Staking hasn't been enabled yet");
        minimumStakingAmount = minAmount;
    }

    function stakeTokens(IERC20 token, uint256 amount) public timestampIsSet noReentrant {
        require(token == erc20Contract, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        require(amount <= token.balanceOf(msg.sender), "Not enough LMS tokens in your wallet, please try lesser amount");
        require(isStakingEnabled==true, "Staking hasn't been enabled yet");
        require(amount>=minimumStakingAmount, "Amount entered is less than minimum staking amount");
        
        uint256 fee = amount.mul(5).div(100);
        uint256 actual = amount.mul(95).div(100);

        token.safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = balances[msg.sender].add(actual);
        jackpotAmount = jackpotAmount.add(fee);
        lastBuyer = msg.sender;
        //86400 - 24hrs
        //jackpotTime is set to 1 min for testing puposes.
        jackpotTime = block.timestamp.add(60);
        
        emit tokensStaked(msg.sender, actual);
    }

    function jackpotWinner(IERC20 token) public jackpotTimePassed noReentrant {
        require(jackpotAmount > 0);
        token.safeTransfer(lastBuyer, jackpotAmount);
        jackpotAmount = 0;
    }

    function unstakeTokens(IERC20 token, uint256 amount) public timestampIsSet noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient token balance, try lesser amount");
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");

        if (block.timestamp >= timePeriod){
            alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(amount);
            balances[msg.sender] = balances[msg.sender].sub(amount);
            token.safeTransfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);    
        } 
        else{
            revert("Tokens are only available after correct time period has elapsed");
        }
    }

    function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        require(token != erc20Contract, "Token address can not be ERC20 address which was passed into the constructor");
        token.safeTransfer(owner, amount);
    }

    function setRewardTimestamp() public onlyOwner  {
        initialRewardTimeStamp = block.timestamp;
    }

    function addRewards(IERC20 token, uint256 _amount) public onlyOwner noReentrant{
        require(_amount > 0, "Amount must be greater than 0");
        token.safeTransferFrom(msg.sender, address(this), _amount);
        totalRewards = totalRewards.add(_amount);
    }

    function setAPR(uint256 _apr) public onlyOwner noReentrant{
        require(_apr > 0, "APR must be greater than 0");
        apr = _apr;
    }

    function caclulateRewards(address _address) public{
        require(initialRewardTimeStamp > 0, "Please set the reward timestamp first");
        require(block.timestamp > initialRewardTimeStamp.add(86400),"24hrs not passed yet");
        initialRewardTimeStamp = block.timestamp;
        stakingReward[_address] = balances[_address].mul(apr).div(365).div(100); 
    }


//PROBLEM : calling calculateRewards() function here would update the rewards only for the address passed in.
//we cannot iterate though a mapping without storing the users in some kind of array and refrencing that when we want to iterate.
// this will be a very expensive operation.

    function withdrawStakingRewards() public {
        
    }

}

//TO DO -
//STAKE time = 24hr
//jackpot time = 24hr

//staking apr  
//keep track of money in total
//add apr once a day in the mapping for all users