// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Web3Pay is Ownable {
    string public constant name = "Web3Pay Contract";
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
        uint256 _price
    ) external onlyOwner {
        require(currencies[IERC20(_currency)].isActive, "Currency not found");
        Item memory item = Item(
            itemCounter++,
            _itemName,
            IERC20(_currency),
            _price,
            true
        );
        items[itemCounter++] = item;
        itemCounter++;
        emit ItemAdded(itemCounter--, _itemName, _currency);
    }

    function deactivateItem(uint256 _itemId) external onlyOwner {
        require(
            items[_itemId].available,
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
            currencies[IERC20(_ERC20ContractAddress)].isActive,
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

    function buyItem(uint256 _itemId) public {
        require(items[_itemId].available, "Item is not available");
        IERC20 token = items[_itemId].currency;
        uint256 balance = token.balanceOf(msg.sender);
        require(items[_itemId].price <= balance, "Buyer has no enough balance");

        token.transferFrom(
            msg.sender,
            currencies[items[_itemId].currency].payeeAddress,
            items[_itemId].price
        );
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
