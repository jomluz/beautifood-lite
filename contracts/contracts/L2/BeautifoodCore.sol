pragma solidity ^0.8.0;
import "./OwnableERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@zetachain/zevm-protocol-contracts/contracts/interfaces/IZRC20.sol";

/**
 * @title Beautifood core contract L2
 * @notice lite version implements a dummy bridge from L1 <> L2
 * @author Carlos Ramos
 */

contract BeautifoodL2 is Ownable {
    struct MenuItem {
        string name;
        uint256 price;
    }

    struct OrderItem {
        uint256 id;
        uint256 qty;
    }

    event L2TokenCreated(
        address newToken,
        address l1TokenAddr,
        string name,
        string symbol
    );

    mapping(address => address) public ercL1toL2;
    mapping(address => bool) isWhitelistedStore;
    mapping(address => MenuItem[]) menuListBySeller;
    mapping(address => uint256) menuLength;

    address public paymentTokenAddr;

    modifier onlyWhitelistedStore() {
        require(isWhitelistedStore[msg.sender], "store is not whitelisted");
        _;
    }

    function deployNewERC20(
        string memory name,
        string memory symbol,
        address l1TokenAddr
    ) external onlyOwner {
        require(ercL1toL2[l1TokenAddr] == address(0), "l2 token already exist");
        OwnableERC20 newToken = new OwnableERC20(name, symbol);
        ercL1toL2[l1TokenAddr] = address(newToken);
        emit L2TokenCreated(address(newToken), l1TokenAddr, name, symbol);
    }

    function mintERC20(
        address to,
        address l1TokenAddr,
        uint256 amount
    ) external onlyOwner {
        require(ercL1toL2[l1TokenAddr] != address(0), "l2 token doesnt exist");
        OwnableERC20(ercL1toL2[l1TokenAddr]).mint(to, amount);
    }

    function addStoreToWhitelist(address _storeAddr) external onlyOwner {
        require(
            isWhitelistedStore[_storeAddr] == false,
            "store already whitelisted"
        );
        isWhitelistedStore[_storeAddr] = true;
    }

    function updateMenu(
        MenuItem[] calldata newMenuList
    ) external onlyWhitelistedStore {
        MenuItem[] storage currMenu = menuListBySeller[msg.sender];
        uint256 i;
        for (i; i < currMenu.length; i++) {
            if (i == newMenuList.length) break;
            currMenu[i] = newMenuList[i];
        }
        for (i; i < newMenuList.length; i++) {
            currMenu.push(newMenuList[i]);
        }
        menuLength[msg.sender] = newMenuList.length;
    }

    function getTotalPriceOfOrder(
        OrderItem[] memory order,
        address seller
    ) public view returns (uint256) {
        uint256 totalAmount;
        for (uint256 i = 0; i < order.length; i++) {
            _checkValidItem(seller, order[i].id);
            uint256 itemTotal = menuListBySeller[seller][order[i].id].price *
                order[i].qty;
            totalAmount += itemTotal;
        }
        return totalAmount;
    }

    function getMenu(address seller) external view returns (MenuItem[] memory) {
        return menuListBySeller[seller];
    }

    // add privacy here using private networks
    function submitOrder(OrderItem[] memory order, address seller) external {
        uint256 amountToTransfer = getTotalPriceOfOrder(order, seller);
        //IERC20(paymentTokenAddr).transferFrom(
        IZRC20(paymentTokenAddr).transferFrom(
            msg.sender,
            address(this),
            amountToTransfer
        );
    }

    function _checkValidItem(address seller, uint256 index) internal view {
        require(menuLength[seller] > index, "item not in the menu");
    }

    function setPaymentToken(address newTokenAddr) external onlyOwner {
        paymentTokenAddr = newTokenAddr;
    }
}
