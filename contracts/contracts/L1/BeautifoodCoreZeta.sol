pragma solidity 0.8.7;
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@zetachain/protocol-contracts/contracts/ZetaInteractor.sol";

/**
 * @title Beautifood core contract L1
 * @notice lite version implements a dummy bridge from L1 <> L2
 * @author Carlos Ramos
 */

contract BeautifoodZeta is ZetaReceiver, ZetaInteractor {
    //using SafeERC20 for IERC20;

    event DepositETH(address sender, uint256 amount);
    event DepositERC20(address sender, address token, uint256 amount);
    address zetaAddr;

    uint256 public constant DEPOSIT_FEE = 20000;

    constructor(
        address _zetaConnector,
        address _zetaAddr
    ) ZetaInteractor(_zetaConnector) {
        zetaAddr = _zetaAddr;
    }

    function onZetaMessage(
        ZetaInterfaces.ZetaMessage calldata zetaMessage
    ) external override isValidMessageCall(zetaMessage) {
        (
            bytes32 messageType,
            address receiverAddress,
            uint256 amountToTransfer
        ) = abi.decode(zetaMessage.message, (bytes32, address, uint256));
        bool success = IERC20(zetaAddr).transfer(
            receiverAddress,
            amountToTransfer
        );
    }

    function onZetaRevert(
        ZetaInterfaces.ZetaRevert calldata zetaRevert
    ) external override {}
}
