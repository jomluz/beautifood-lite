pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Beautifood core contract L2
 * @notice lite version implements a dummy bridge from L1 <> L2
 * @author Carlos Ramos
 */

contract BeautifoodL2 {
    event L2TokenCreated(
        address newToken,
        address l1TokenAddr,
        string name,
        string symbol
    );

    mapping(address => address) public ercL1toL2;

    // onlyOwner
    function deployNewERC20(
        string memory name,
        string memory symbol,
        address l1TokenAddr
    ) external {
        require(ercL1toL2[l1TokenAddr] == address(0), "l2 token already exist");
        ERC20 newToken = new ERC20(name, symbol);
        ercL1toL2[l1TokenAddr] = address(newToken);
        emit L2TokenCreated(address(newToken), l1TokenAddr, name, symbol);
    }

    // onlyOwner
    function mintERC20(
        address to,
        address l1TokenAddr,
        uint256 amount
    ) external {
        require(ercL1toL2[l1TokenAddr] != address(0), "l2 token doesnt exist");
    }
}
