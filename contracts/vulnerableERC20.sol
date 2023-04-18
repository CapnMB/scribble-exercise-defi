pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title A DeFi Smart Contract with mistakes for fuzz testing
/// @notice This smart contract contains mistakes that can be caught by a fuzz tester

contract VulnerableToken is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public token;

    struct DepositInfo {
        uint256 amount;
        uint256 depositTimestamp;
    }

    mapping(address => DepositInfo) public deposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    /// @param _token Address of the ERC20 token
    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

    /// #invariant forall (address user in deposits) token.balanceOf(address(this)) >= deposits[user].amount;
    /// #invariant token.balanceOf(address(this)) == sum(address user in deposits, uint256 depositAmount in deposits[user].amount);

    /// @notice Allows users to deposit tokens
    /// @param _amount Amount of tokens to deposit
    function deposit(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");

        // Mistake: User's previous deposit will be overwritten without withdrawal
        // #safemath
        deposits[msg.sender].amount += _amount; // fixed using SafeMath

        token.safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount);
    }

    /// @notice Allows users to withdraw their tokens
    /// @param _amount Amount of tokens to withdraw
    function withdraw(uint256 _amount) external nonReentrant {
        DepositInfo storage userDeposit = deposits[msg.sender];
        require(userDeposit.amount >= _amount, "Insufficient balance");

        // Mistake: No time lock for the withdrawal
        // #timelock
        require(
            block.timestamp >= userDeposit.depositTimestamp + 3600,
            "Withdrawal is not yet available"
        ); // added time lock

        userDeposit.amount -= _amount;

        token.safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    /// @notice Calculates interest for the user
    /// @param _user Address of the user
    /// @return Interest amount
    /// @dev This function contains an overflow bug
    function calculateInterest(address _user) external view returns (uint256) {
        DepositInfo storage userDeposit = deposits[_user];
        uint256 depositDuration = block.timestamp -
            userDeposit.depositTimestamp;

        // Mistake: Overflow bug in interest calculation
        // #safemath
        uint256 interest = depositDuration * userDeposit.amount * 1000; // fixed using SafeMath

        return interest;
    }
}
