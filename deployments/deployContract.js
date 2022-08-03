const { ethers } = require("hardhat")

const main = async () => {
    //const initialCount = ethers.utils.parseEther("1");

    const[deployer] = await ethers.getSigners();
    console.log(`Address deploying the contract --> ${deployer.address}`);

    const contractFactory = await ethers.getContractFactory("ERC20Pay");
    const contract = await contractFactory.deploy("0x07865c6E87B9F70255377e024ace6630C1Eaa37F", "0xf73bEe14bA3D2313609503237E1FCAdcE764a665", "USDC");

    console.log(`Contract address --> ${contract.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });