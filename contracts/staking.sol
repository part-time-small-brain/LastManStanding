// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract SimpleStaking {
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

    mapping(address => uint256) public alreadyWithdrawn;
    mapping(address => uint256) public balances;

    IERC20 public erc20Contract;

    event tokensStaked(address from, uint256 amount);
    event TokensUnstaked(address to, uint256 amount);

    constructor(IERC20 _erc20_contract_address) {
        owner = msg.sender;
        timestampSet = false;
        require(address(_erc20_contract_address) != address(0), "_erc20_contract_address address can not be zero");
        erc20Contract = _erc20_contract_address;
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
        require(block.timestamp >= jackpotTime, "Jacpot TIme has not been passed yet.");
        _;
    }

    function setTimestamp(uint256 _timePeriodInSeconds) public onlyOwner timestampNotSet  {
        timestampSet = true;
        initialTimestamp = block.timestamp;
        timePeriod = initialTimestamp.add(_timePeriodInSeconds);
    }

    function stakeTokens(IERC20 token, uint256 amount) public timestampIsSet noReentrant {
        require(token == erc20Contract, "You are only allowed to stake the official erc20 token address which was passed into this contract's constructor");
        require(amount <= token.balanceOf(msg.sender), "Not enough STATE tokens in your wallet, please try lesser amount");
        uint256 fee = amount*5/100;
        uint256 actual = amount*95/100;

        token.safeTransferFrom(msg.sender, address(this), amount);
        // token.safeTransferFrom(msg.sender, jackpotWallet, fee);
        balances[msg.sender] = balances[msg.sender].add(actual);
        jackpotAmount += fee;
        lastBuyer = msg.sender;
        //86400 - 24hrs
        jackpotTime = block.timestamp.add(60);
        
        emit tokensStaked(msg.sender, actual);
    }

    function winner(IERC20 token) public jackpotTimePassed noReentrant {
        require(jackpotAmount > 0);
        token.safeTransfer(lastBuyer, jackpotAmount);
        jackpotAmount = 0;
    }

    function unstakeTokens(IERC20 token, uint256 amount) public timestampIsSet noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient token balance, try lesser amount");
        require(token == erc20Contract, "Token parameter must be the same as the erc20 contract address which was passed into the constructor");
        if (block.timestamp >= timePeriod) {
            alreadyWithdrawn[msg.sender] = alreadyWithdrawn[msg.sender].add(amount);
            balances[msg.sender] = balances[msg.sender].sub(amount);
            token.safeTransfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);    
        } else {
            revert("Tokens are only available after correct time period has elapsed");
        }
    }

    function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlyOwner noReentrant {
        require(address(token) != address(0), "Token address can not be zero");
        require(token != erc20Contract, "Token address can not be ERC20 address which was passed into the constructor");
        token.safeTransfer(owner, amount);
    }
}

//TO DO -
//STAKE time = 24hr
// jackpot time = 24hr