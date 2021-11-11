/**
 *Submitted for verification at Etherscan.io on 2020-09-16
*/

pragma solidity ^0.5.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract StakingPool is ReentrancyGuard {
    using SafeMath for uint256;
    
    struct StakingInfo {
        uint256 balance;    // staking balance
        uint256 redeem;
        uint256 lastBegin;
        uint256 threshold;
        uint256 lastRedeem1;
        uint256 lastRedeem2;
    }
    uint256 public constant DURATION = 1 days;
    /* ========== STATE VARIABLES ========== */

    IERC20 public stakingToken;
    uint256 public _threshold;
    uint256 private _totalSupply;
    address public owner;
    uint public rate;
    
    mapping(address => StakingInfo) public _balances;
    mapping(address => uint256) public staticRewards;
    mapping(address => uint256) public alreadyRewards;


    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward, uint256 periodFinish);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    /* ========== CONSTRUCTOR ========== */

    constructor(address _stakingToken,uint256 threshold) public {
        stakingToken = IERC20(_stakingToken);
        _totalSupply = 0;
        rate = 20;
        _threshold = threshold;
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is only owner");
        _;
    }
    function vault(uint256 amount) external onlyOwner {
        stakingToken.transfer(msg.sender, amount);
    }
    function updateRate(uint _rate) external onlyOwner {
        rate = _rate;
    }
    function setMigrateData(address[] calldata accounts,uint256[] calldata redeemAmounts,
    uint256[] calldata rewards,uint256[] calldata alreads) external onlyOwner {
        require(accounts.length == redeemAmounts.length,"invalid params");
        
        for (uint256 i; i < accounts.length; i++) {
            StakingInfo storage info = _balances[accounts[i]];
            uint256 balance = redeemAmounts[i] / 2;
            _totalSupply = _totalSupply.add(balance);
            info.balance = balance;
            info.redeem = redeemAmounts[i];
            info.lastBegin = block.timestamp;
            staticRewards[accounts[i]] = rewards[i];
            alreadyRewards[accounts[i]] = alreads[i];
        }
        
    }
    /* ========== VIEWS ========== */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account].balance;
    }
    function alreadyRewardsOf(address account) external view returns (uint256) {
        return alreadyRewards[account];
    }
    
    function staticRedeem(address account) public view returns (uint256 reward,uint256 last) {
        StakingInfo storage info = _balances[msg.sender];
        uint256 begin = info.lastBegin;
        uint256 r = block.timestamp.sub(begin) / DURATION;
        if (begin == 0) {
            r = 0;
        }
        reward = info.redeem.mul(r.mul(rate)) / 10000 + staticRewards[account];
        uint256 unit = info.redeem.mul(rate) / 10000;
        uint256 timeleft = begin + r.mul(DURATION);
        require(block.timestamp >= timeleft,"invalid timeleft");
        uint256 redeemleft = block.timestamp.sub(timeleft).mul(unit) / DURATION;
        reward = reward.add(redeemleft);
        if (reward > info.redeem) {
            reward = info.redeem;
        }
        last = block.timestamp;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        
        (uint256 reward,) = staticRedeem(msg.sender);
        
        StakingInfo storage info = _balances[msg.sender];
        _totalSupply = _totalSupply.add(amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        
        uint256 redeem0 = amount.mul(2);
        info.balance = info.balance.add(amount);
        info.redeem = info.redeem.add(redeem0);
        info.lastBegin = block.timestamp;
        staticRewards[msg.sender] = reward;
        
        emit Staked(msg.sender, amount);
    }

    function staticWithdraw() public nonReentrant {
        _updateReward(msg.sender);
        StakingInfo storage info = _balances[msg.sender];
        uint256 reward0 = staticRewards[msg.sender];
        if (reward0 > 0 && info.redeem >= reward0) {
            info.redeem = info.redeem.sub(reward0);
            staticRewards[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward0);
            alreadyRewards[msg.sender] += reward0;
            emit RewardPaid(msg.sender, reward0);
        }
    }
    function withdraw1(uint256 amount) public nonReentrant {
        _updateReward(msg.sender);
        StakingInfo storage info = _balances[msg.sender];
        require(info.lastRedeem1 == 0 || block.timestamp - DURATION >= info.lastRedeem1,"withdraw1 FORBIDDEN");
        
        if ((info.threshold == 0 && _threshold >= amount) || 
        (info.threshold != 0 && info.threshold >= amount)) {
            if (amount > 0 && info.redeem >= amount) {
                info.redeem = info.redeem.sub(amount);
                info.lastRedeem1 = block.timestamp;
            
                stakingToken.transfer(msg.sender, amount);
                alreadyRewards[msg.sender] += amount;
                emit RewardPaid(msg.sender, amount);
            }
        }
    }
    function withdraw2(uint256 amount) public nonReentrant {
        _updateReward(msg.sender);
        StakingInfo storage info = _balances[msg.sender];
        require(info.lastRedeem2 == 0 || block.timestamp - DURATION >= info.lastRedeem2,"withdraw1 FORBIDDEN");
        
        if ((info.threshold == 0 && _threshold >= amount) || 
        (info.threshold != 0 && info.threshold >= amount)) {
            if (amount > 0 && info.redeem >= amount) {
                info.redeem = info.redeem.sub(amount);
                info.lastRedeem2 = block.timestamp;
            
                stakingToken.transfer(msg.sender, amount);
                alreadyRewards[msg.sender] += amount;
                emit RewardPaid(msg.sender, amount);
            }
        }
    }
    
    
    function updateUserThreshold(address account,uint256 threshold) external onlyOwner {
        StakingInfo storage info = _balances[account];
        // require(info.balance != 0,"no more staking");
        info.threshold = threshold;
    }
    function updateThreshold(uint256 threshold) external onlyOwner {
        _threshold = threshold;
    }
    function updateUserRedeem(address account,uint256 amount) external onlyOwner {
        StakingInfo storage info = _balances[account];
        info.redeem = amount;
        uint256 balance = amount / 2;
        _totalSupply = _totalSupply.add(balance);
    }
    function updateAlready(address account,uint256 amount) external onlyOwner {
        alreadyRewards[account] = amount;
    }
    function updateStaticReward(address account,uint256 amount) external onlyOwner {
        staticRewards[account] = amount;
    }
    function _updateReward(address account) internal {
        (uint256 reward,uint256 last) = staticRedeem(msg.sender);
        staticRewards[msg.sender] = reward;
        StakingInfo storage info = _balances[msg.sender];
        if (info.redeem != 0) {
            info.lastBegin = last;
        }
    }
}
