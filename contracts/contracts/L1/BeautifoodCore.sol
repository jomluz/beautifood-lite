pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@zetachain/zevm-protocol-contracts/contracts/interfaces/IZRC20.sol";

/**
 * @title Beautifood core contract L1
 * @notice lite version implements a dummy bridge from L1 <> L2
 * @author Carlos Ramos
 */

contract Beautifood {
    event DepositETH(address sender, uint256 amount);
    event DepositERC20(address sender, address token, uint256 amount);
    event DepositZRC20(address sender, address token, uint256 amount);

    uint256 public constant DEPOSIT_FEE = 20000;

    function depositETH() external payable {
        require(DEPOSIT_FEE < msg.value, "Amount not enough");
        uint256 validAmount = msg.value - DEPOSIT_FEE;
        emit DepositETH(msg.sender, validAmount);
    }

    function depositERC20(uint256 amount, address ercAddr) external {
        // TODO: check for oracle price of asset in eth for gas
        IERC20(ercAddr).transferFrom(msg.sender, address(this), amount);
        emit DepositERC20(msg.sender, ercAddr, amount);
    }

    function depositZRC20(uint256 amount, address ercAddr) external {
        // TODO: check for oracle price of asset in eth for gas
        IZRC20(ercAddr).transferFrom(msg.sender, address(this), amount);
        emit DepositZRC20(msg.sender, ercAddr, amount);
    }
}
