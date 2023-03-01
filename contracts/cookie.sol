pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CookieCapital is ERC20 {

    ERC20 private _stakedToken;
    address public _stakedTokenAddress;
    uint256 public _totalCookiesEaten;

    mapping (address => uint256) public _staked;
    mapping (address => uint256) public _cookiePower;
    mapping (address => uint256) public _lastStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 amount);
    event Eat(address indexed user, uint256 amount);

    constructor (address stakedTokenAddress) ERC20("Cookies", "COK") {
        _stakedTokenAddress = stakedTokenAddress;
        _stakedToken = ERC20(stakedTokenAddress);
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Must stake more than 0 tokens.");
        if (_staked[msg.sender] > 0) {
            unstake();
        }
        _stakedToken.transferFrom(msg.sender, address(this), amount);
        _staked[msg.sender] = amount;
        _lastStaked[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    function unstake() public {
        require(_staked[msg.sender] > 0, "You need to stake before unstaking.");
        harvest();
        uint256 staked = _staked[msg.sender];
        _staked[msg.sender] = 0;
        _stakedToken.transfer(msg.sender, staked);
        emit Unstaked(msg.sender, staked);
    }

    function calculateProfit(address addr) public view returns (uint256 profit) {
        uint256 hoursSpent = ((block.timestamp - _lastStaked[addr]) * 1000) / 3600;
        uint256 cookieMultiplier = (1000 + _cookiePower[addr]);
        uint256 cookies = (_staked[addr] * hoursSpent * cookieMultiplier) / 1000;
        return cookies;
    }

    function harvest() public returns (uint256 earnedCookies) {
        require(_staked[msg.sender] > 0, "You haven't staked anything.");
        uint256 cookies = calculateProfit(msg.sender);
        _lastStaked[msg.sender] = block.timestamp;
        _mint(msg.sender, cookies);
        emit Harvest(msg.sender, cookies);
        return cookies;
    }

    function eat(uint256 amount) public {
        harvest();
        require(amount >= (1000 * 10**18), "Must eat at least 1000 cookies.");
        require(balanceOf(msg.sender) >= amount, "Not enough cookies in balance.");
        uint256 remaining = amount % (1000 * 10**18);
        _burn(msg.sender, amount - remaining);
        _cookiePower[msg.sender] += (amount - remaining) / (1000 * 10**18);
        emit Eat(msg.sender, (amount - remaining));
    }

    function harvestAndEat() public {
        require((calculateProfit(msg.sender) + balanceOf(msg.sender)) > (1000 * 10**18), "Must eat more than 1000 cookies.");
        uint256 harvested = harvest();
        eat(harvested);
    }
}