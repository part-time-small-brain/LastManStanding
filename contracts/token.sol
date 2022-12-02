// SPDX-License-Identifier: GLP-3.0

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract LastManStanding is ERC20, ERC20Burnable, Ownable {
    event tokensburned(address indexed owner, uint256 amount, string message);
    event tokensMinted(address indexed owner, uint256 amount, string message);
    event additionaltoken(address indexed owner, uint256 amount,string message);

    constructor() ERC20("LastManStanding", "LMS"){
        //decimals is 18 here
        _mint(msg.sender, 100000*10**decimals());
        emit tokensMinted(msg.sender, 100000*10**decimals(), "Initial supply");
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit additionaltoken(msg.sender, amount, "Addition LMS minted.");
    }

    //overriding ERC20 to use burn function of ERC20Burnable
    function burn(uint256 amount) public override onlyOwner{
        _burn(msg.sender, amount);
        emit tokensburned(msg.sender, amount, "LMS Burned");
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool){
        address owner = _msgSender();
        uint256 fee = _value/100; // for 1% fee
        uint256 actual = _value*99/100;             
        _transfer(owner,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, fee);   
        _transfer(owner, _to, actual);         
        return true;            
    }
}