// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract Web3Pay is Ownable {
    string public constant name = "Web3Pay Contract";
    uint256 private itemCounter;

    mapping(uint256 => Item) items;
    //currencyAddress => paymentAddress
    mapping(address => Currency) currencies;

    struct Currency {
        string name;
        address payeeAddress;
    }
    struct Item {
        uint256 itemId;
        string itemName;
        Currency currency;
        bool available;
    }

    constructor(
        address _currencyERC20Address,
        address _payeeAddress,
        string memory _currencyName
    ) {
        Currency memory currency = Currency(_currencyName, _payeeAddress);
        currencies[_currencyERC20Address] = currency;
        itemCounter = 0;
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
