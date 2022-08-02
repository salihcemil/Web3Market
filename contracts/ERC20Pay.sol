// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20Pay is Ownable {
    string public constant name = "ERC20Pay";
    uint256 private itemCounter;

    mapping(uint256 => Item) items;
    //currencyAddress => paymentAddress
    mapping(IERC20 => Currency) currencies;

    struct Currency {
        string name;
        address payeeAddress;
        bool isActive;
    }
    struct Item {
        uint256 itemId;
        string itemName;
        IERC20 currency;
        uint256 price;
        bool available;
        uint256 quantity;
    }

    event ItemAdded(
        uint256 indexed itemNo,
        string indexed name,
        address indexed currency
    );
    event ItemDeactivated(uint256 indexed itemNo);
    event CurrencyAdded(string currencyName);
    event CurrencyDisabled(string currencyName);
    event PayeeAddressUpdated(
        address indexed currencyAddres,
        address newPayeeAddress
    );
    event ItemBought(
        uint256 indexed itemId,
        address indexed buyer,
        uint256 amount,
        uint256 quantity
    );

    constructor(
        address _currencyERC20Address,
        address _payeeAddress,
        string memory _currencyName
    ) {
        Currency memory currency = Currency(_currencyName, _payeeAddress, true);
        currencies[IERC20(_currencyERC20Address)] = currency;
        itemCounter = 0;
    }

    function addItem(
        string memory _itemName,
        address _currency,
        uint256 _price,
        uint256 _quantity
    ) external onlyOwner returns (uint256) {
        require(
            currencies[IERC20(_currency)].isActive == true,
            "Currency not found"
        );
        Item memory item = Item(
            itemCounter,
            _itemName,
            IERC20(_currency),
            _price,
            true,
            _quantity
        );
        items[itemCounter] = item;
        itemCounter = itemCounter + 1;
        emit ItemAdded(itemCounter - 1, _itemName, _currency);
        return itemCounter - 1;
    }

    function deactivateItem(uint256 _itemId) external onlyOwner {
        require(
            items[_itemId].available == true,
            "Item not found or already deactivated"
        );
        items[_itemId].available = false;
        emit ItemDeactivated(_itemId);
    }

    function addCurrency(
        address _ERC20ContractAddress,
        address _payeeAddress,
        string memory _currencyName
    ) external onlyOwner {
        require(
            currencies[IERC20(_ERC20ContractAddress)].isActive == false,
            "Currency already added"
        );
        Currency memory currency = Currency(_currencyName, _payeeAddress, true);
        currencies[IERC20(_ERC20ContractAddress)] = currency;
        emit CurrencyAdded(_currencyName);
    }

    function disableCurrency(address _ERC20ContractAddress) external onlyOwner {
        require(
            currencies[IERC20(_ERC20ContractAddress)].isActive,
            "Currency not active"
        );
        currencies[IERC20(_ERC20ContractAddress)].isActive = false;
        emit CurrencyDisabled(currencies[IERC20(_ERC20ContractAddress)].name);
    }

    function updatePayeeAddressOfCurrency(
        address _currencyAddress,
        address _newPayeeAddress
    ) external onlyOwner {
        require(
            currencies[IERC20(_currencyAddress)].isActive,
            "Currency is not available"
        );
        currencies[IERC20(_currencyAddress)].payeeAddress = _newPayeeAddress;
        emit PayeeAddressUpdated(_currencyAddress, _newPayeeAddress);
    }

    function buyItem(uint256 _itemId, uint256 _desiredQuantity) public {
        require(items[_itemId].available, "Item is not available");
        require(
            items[_itemId].quantity >= _desiredQuantity,
            "Desired quantity is over than stock"
        );
        IERC20 token = items[_itemId].currency;
        uint256 balance = token.balanceOf(msg.sender);
        require(
            items[_itemId].price * _desiredQuantity <= balance,
            "Buyer has no enough balance"
        );
        require(
            items[_itemId].price * _desiredQuantity <=
                token.allowance(msg.sender, address(this)),
            "Please check allowance amount"
        );

        token.transferFrom(
            msg.sender,
            currencies[items[_itemId].currency].payeeAddress,
            items[_itemId].price
        );

        items[_itemId].quantity = items[_itemId].quantity - _desiredQuantity;

        if (items[_itemId].quantity == 0) {
            this.deactivateItem(_itemId);
        }

        emit ItemBought(
            _itemId,
            msg.sender,
            items[_itemId].price,
            _desiredQuantity
        );
    }

    function getCurrency(address _currencyAddress)
        public
        view
        returns (Currency memory)
    {
        return currencies[IERC20(_currencyAddress)];
    }

    function getItem(uint256 _itemId) public view returns (Item memory) {
        return items[_itemId];
    }

    function getOwner() public view returns (address) {
        return this.owner();
    }

    function getName() public pure returns (string memory) {
        return name;
    }

    function getItemCounter() public view onlyOwner returns (uint256) {
        return itemCounter;
    }
}
