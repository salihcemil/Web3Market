const { ethers } = require("hardhat")

const main = async () => {
    //const initialCount = ethers.utils.parseEther("1");

    const[deployer] = await ethers.getSigners();
    console.log(`Address deploying the contract --> ${deployer.address}`);

    const contractFactory = await ethers.getContractFactory("Web3Pay");
    const contract = await contractFactory.deploy();

    console.log(`Contract address --> ${contract.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });