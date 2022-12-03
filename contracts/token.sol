// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract LastManStanding is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;
    
    address devWallet;    

    constructor() ERC20("LastManStanding", "LMS"){
        //decimals is 18 here
        //100,000 tokens
        _mint(msg.sender, 100000*10**decimals());
    }

    function setDevWallet(address _devWallet) public onlyOwner {
        devWallet = _devWallet;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public override onlyOwner {
        _burn(msg.sender, amount);
    }
    
    function transfer(address _to, uint256 _amount) public virtual override returns(bool) {
        address owner = _msgSender();
        uint256 fee;
        uint256 actual;

        fee = _amount.mul(2).div(100);
        actual = _amount.mul(98).div(100);
        _transfer(owner,devWallet, fee);
        _transfer(owner, _to, actual);

        return true;
    }
}