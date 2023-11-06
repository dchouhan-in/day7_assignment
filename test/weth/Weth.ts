import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Assets, WETH, WETH__factory, Coins } from "../../typechain-types";
// Runtime Environment's members available in the global scope.
import hre from "hardhat";


describe("Main", function () {
    let weth: any
    let owner: HardhatEthersSigner
    let otherAccount: HardhatEthersSigner
    let otherAccount2: HardhatEthersSigner
    let wethAddress: string
    let ownerAddress: string
    let otherAccountAddress: string
    let otherAccount2Address: string


    describe("weth", async function () {
        const tokenName = "dummy wrapped ether"
        const tokenSymbol = "WETH"

        before("Deploy weth Contract!", async () => {
            [owner, otherAccount, otherAccount2] = await ethers.getSigners();

            ownerAddress = await owner.getAddress();
            otherAccountAddress = await otherAccount.getAddress();
            otherAccount2Address = await otherAccount2.getAddress();


            weth = await ethers.deployContract("WETH", owner);

            wethAddress = await weth.getAddress()

            await weth.waitForDeployment();

            const ownerBalance = await weth.balanceOf(owner.address);

            expect(await weth.totalSupply()).to.equal(ownerBalance);

        });

        it("should have the correct name and symbol", async () => {
            const name = await weth.name();
            const symbol = await weth.symbol();
            expect(name).to.equal(tokenName)
            expect(symbol).to.equal(tokenSymbol)
        });


        it("should have the correct total supply", async () => {
            const totalSupply = await weth.totalSupply();
            expect(totalSupply).to.equal(0)
        });

        it("should have the correct decimals", async () => {
            const decimals = await weth.decimals();
            expect(decimals).to.equal(10)
        });

        it("should deposit ether", async () => {
            const initalEthersBalance = await ethers.provider.getBalance(ownerAddress);

            await weth.deposit({ value: BigInt(10e18) });
            const balance = await weth.balanceOf(owner)
            expect(balance).to.equals(1e10)
            const currentEthers = await ethers.provider.getBalance(ownerAddress);
            expect(currentEthers).to.lessThan(initalEthersBalance - BigInt(10e9))
            const currentSupply = await weth.totalSupply();
            expect(currentSupply).to.equals(1e10);

        });

        it("should withdraw ether", async () => {
            const balanceContractInitial = await ethers.provider.getBalance(wethAddress);

            const initialEthers = await ethers.provider.getBalance(ownerAddress);
            await weth.withdraw(5 * 1e9);

            const balance = await weth.balanceOf(owner)
            const balanceContractCurrent = await ethers.provider.getBalance(wethAddress);
            const currentEthers = await ethers.provider.getBalance(ownerAddress);
            expect(balance).to.equals(5 * 10e8);
            expect(balanceContractInitial).to.be.greaterThan(balanceContractCurrent);

            expect(currentEthers).to.be.greaterThan(initialEthers);
        });

    });
    describe("contract factory", async function () {
        const Factory = await hre.ethers.getContractFactory("WETH");
        const weth = await Factory.deploy();
        console.log("weth deployed to:", await weth.getAddress());
        const coinsFactory = await hre.ethers.getContractFactory("Coins");
        const coins = await coinsFactory.deploy("TEST", "TS");

        expect(await coins.symbol()).to.be("TS")
        expect(await coins.name()).to.be("TEST")

        console.log("coins deployed to:", await weth.getAddress());


    });

});