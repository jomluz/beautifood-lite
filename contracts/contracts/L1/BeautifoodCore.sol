pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@zetachain/protocol-contracts/contracts/ZetaInteractor.sol";
import "@zetachain/protocol-contracts/contracts/interfaces/ZetaInterfaces.sol";
import "@zetachain/zevm-protocol-contracts/contracts/interfaces/IZRC20.sol";

/**
 * @title Beautifood core contract L1
 * @notice lite version implements a dummy bridge from L1 <> L2
 * @author Carlos Ramos
 */

contract Beautifood is ZetaInteractor, ZetaReceiver {
    event DepositZeta(address sender, uint256 amount);
    address zetaAddr;
    uint256 zetaChainId;
    bytes32 public constant DEPOSIT_ZETA = keccak256("DEPOSIT_ZETA");
    bytes32 public constant WITHDRAW_ZETA = keccak256("WITHDRAW_ZETA");

    constructor(
        address _zetaConnector,
        address _zetaAddr,
        uint256 _zetaChainId // all tokens go to athens
    ) ZetaInteractor(_zetaConnector) {
        zetaAddr = _zetaAddr;
        zetaChainId = _zetaChainId;
    }

    function onZetaMessage(
        ZetaInterfaces.ZetaMessage calldata zetaMessage
    ) external override {}

    function onZetaRevert(
        ZetaInterfaces.ZetaRevert calldata zetaRevert
    ) external override {}

    function depositZeta(
        uint256 amount,
        uint256 crossChaindestinationGasLimit
    ) external {
        // TODO: check for oracle price of asset in eth for gas
        //IERC20(zetaAddr).transferFrom(msg.sender, address(this), amount);
        IZRC20(zetaAddr).transferFrom(msg.sender, address(this), amount);

        emit DepositZeta(msg.sender, amount);

        connector.send(
            ZetaInterfaces.SendInput({
                destinationChainId: zetaChainId,
                destinationAddress: interactorsByChainId[zetaChainId],
                destinationGasLimit: crossChaindestinationGasLimit,
                message: abi.encode(DEPOSIT_ZETA, msg.sender, amount),
                zetaValueAndGas: amount,
                zetaParams: abi.encode("")
            })
        );
    }
}
