# Web3Market

<!-- ABOUT THE PROJECT -->

## About The Project

This is a sample project of a compact web3 payment system.

_Please note that it has not been audited for production environment usage yet_

The project mainly consists of the Web3Market contract, a basic ERC20 token contract for tests, the test scrpts, the deployment scripts and configurations.

The main contract was inherited as ownable from OpenZeppelin. So there is only one specified role and it's the **Owner**.

The Owner is responsible to add **Items** and **Currencies**, maintain the available stocks, items and currences' availability.

Currency is a struct that keeps related ERC20 contract address which lets users to buy items with specific ERC20 tokens.

The main focus on thi project is **StableCoins** such as USDT and USDC.

Each item is listed in a specific currency with IERC interface. It's possible to add new ERC20 tokens and disable the current ones.

### Flows

Once the contract was deployed, the deployer will be the Owner. Owner can add currency and items. Please note that an initial ERC20 token contract address must be specified at the deployment.

Regular users can call buyItem function with an itemId and quantity.

**Please note that, before buying the user should approve to the contract spents his/her tokens**

The UI component needs to call ERC20 token contract's approve function with the related amount before buying the item. This process cannot done on the contract's end.

![System Overview][web3market_diagram]

This project focuses only the ethereum smart contract. In production, an offchain system can maintain the rest with an outer database. The offchain system can subscribe and listen the contract events and manage the rest.

### Limitations

### Future Works

## Installation

In this section, installation and running instructions are explained.

### Prerequisites

The project is implemented on node.js so please be sure that node and package manager are installed in your environment. To check it, simply run

```sh
node -v
```

```
npm -v
or
npm --version
```

### Dependencies

The project is implemented on

```
hardhat
```

For ethereum related operations:

```
@nomiclabs/hardhat-ethers
@nomiclabs/hardhat-etherscan
@nomiclabs/hardhat-waffle
ethers
```

For OpenZeppelin:

```
@openzeppelin/contracts-upgradeable
@openzeppelin/hardhat-upgrades
```

For js tests:

```
chai
ethereum-waffle
```

To run the project:

First, it doesn't contain a .env file because of the nature of web3 apps. Please be sure that you've created your .env file with your credentials and never share/post it.

To create .env file

```sh

touch .env

```

The .env file should look like below

```sh

PRIVATE_KEY = <HERE_COMES_YOUR_PRIVATE_KEY>

RINKEBY_URL = <ALCHEMY_RINKEBY_URL>

ETHERSCAN_KEY = <ETHERSCAN_KEY>

```

Ethereum Rinkeby Network is used for test deployments. Feel free to deploy it to other EVM-compatible testnets. To deploy the project to a different network, don't forget to update the hardhat.config.js and deployProxy.js file.

<p  align="right">(<a  href="#top">back to top</a>)</p>

## Deployment Quick Tips

To compile contracts:

```sh

npx hardhat compile

```

To run the tests:

```sh

npx hardhat test

```

To deploy the contract to Rinkeby Testnet:

```sh

npx hardhat run deployments/deployProxy.js --network rinkeby

```

To verify the contract on Rinkeby Testnet:

```sh

hardhat verify — network <networkName> <contractAddress> <ConstructorArguments>

```

in this case

```sh

npx hardhat verify --network rinkeby <CONTRACT_ADDRESS>

```

<p  align="right">(<a  href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[system-overview]: images/Web3Market_diagram.png
