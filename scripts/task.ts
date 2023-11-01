import { task } from "hardhat/config";
import { WETH } from "../typechain-types";

task("balances", "Prints the balances of all the addresses!")
    .addParam("contract", "contract address")
    .addParam("count", "number of addresses to query!")
    .setAction(async (arg) => {

        const signers: Array<any> = await ethers.getSigners()
        const contract = await ethers.getContractAt("WETH", arg.contract)

        for (const signer of signers.slice(0, arg.count)) {
            const balance = await contract.balanceOf(signer.address)
            console.log(signer.address, "-", balance);
        }

    })


task("deposit", "Deposit to a weth contract!")
    .addParam("contract", "Contract address")
    .addParam("amount", "Amount to deposit")
    .setAction(async (arg) => {
        const signers = await ethers.getSigners();
        const contract: WETH = await ethers.getContractAt("WETH", arg.contract);
        const signer = signers[0];

        // Convert the amount to a BigNumber
        const amountToDeposit = ethers.parseEther(arg.amount.toString());

        // Ensure the signer has sufficient balance
        const signerBalance = await ethers.provider.getBalance(signer.address);
        console.log("signerBalance - ", signerBalance, "\n", "toDeposit - ", amountToDeposit);

        if (signerBalance < amountToDeposit) {
            console.error("Signer does not have enough balance to deposit the specified amount.");
            return;
        }

        // Perform the deposit
        const tx = await contract.connect(signer).deposit({ value: amountToDeposit });
        await tx.wait();


        console.log(`Deposited ${ethers.formatEther(amountToDeposit)} tokens into the contract.`,
            "\n",
            "for reference txn-hash - ", tx.hash);
    });


task("withdraw", "Deposit to a weth contract!")
    .addParam("contract", "Contract address")
    .addParam("amount", "Amount to deposit")
    .setAction(async (arg) => {
        const signers = await ethers.getSigners();
        const contract: WETH = await ethers.getContractAt("WETH", arg.contract);
        const signer = signers[0];

        // Convert the amount to a BigNumber
        const amountToWithdraw = BigInt(arg.amount.toString());


        const signerBalance = await ethers.provider.getBalance(signer.address);
        console.log("signerBalance - ", signerBalance, "\n", "toWithdraw - ", amountToWithdraw);

        // Perform the deposit
        const tx = await contract.connect(signer).withdraw(amountToWithdraw, { value: amountToWithdraw });
        await tx.wait();


        console.log(`Withdrawn ${ethers.formatEther(amountToWithdraw)} tokens into the contract.`,
            "\n",
            "for reference txn-hash - ", tx.hash);
    });