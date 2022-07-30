// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Web3Pay is Ownable {
    string public constant name = "Web3Pay Contract";
    uint256 private itemCounter;

    mapping(uint256 => Item) items;
    //currencyAddress => paymentAddress
    mapping(address => Currency) currencies;

    struct Currency {
        string name;
        address payeeAddress;
        bool isActive;
    }
    struct Item {
        uint256 itemId;
        string itemName;
        address currency;
        bool available;
    }

    event ItemAdded(
        uint256 indexed itemNo,
        string indexed name,
        address currency
    );
    event ItemDeactivated(uint256 indexed itemNo);
    event CurrencyAdded(string currencyName);
    event CurrencyDisabled(string currencyName);

    constructor(
        address _currencyERC20Address,
        address _payeeAddress,
        string memory _currencyName
    ) {
        Currency memory currency = Currency(_currencyName, _payeeAddress, true);
        currencies[_currencyERC20Address] = currency;
        itemCounter = 0;
    }

    function addItem(string memory _itemName, address _currency)
        external
        onlyOwner
    {
        require(currencies[_currency].isActive, "Currency not found");
        Item memory item = Item(itemCounter++, _itemName, _currency, true);
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
            currencies[_ERC20ContractAddress].isActive,
            "Currency already added"
        );
        Currency memory currency = Currency(_currencyName, _payeeAddress, true);
        currencies[_ERC20ContractAddress] = currency;
        emit CurrencyAdded(_currencyName);
    }

    function disableCurrency(address _ERC20ContractAddress) external onlyOwner {
        require(
            currencies[_ERC20ContractAddress].isActive,
            "Currency not active"
        );
        currencies[_ERC20ContractAddress].isActive = false;
        emit CurrencyDisabled(currencies[_ERC20ContractAddress].name);
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
