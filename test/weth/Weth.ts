import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Assets, weth } from "../typechain-types";
import { AttackerContract, TargetContract } from "../../typechain-types";


describe("Main", function () {
    let weth: weth
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

    describe("reentrancy", async () => {

        let target: TargetContract
        let attacker: AttackerContract

        before("deploy!", async () => {
            const targetFactory = await ethers.getContractFactory("TargetContract");
            target = await targetFactory.deploy({ value: ethers.parseUnits("100") });
            await target.waitForDeployment();
            const attackerFactory = await ethers.getContractFactory("AttackerContract");
            attacker = await attackerFactory.deploy(target);
            await attacker.waitForDeployment();
        })

        it("target contract must have 100 ethers!", async () => {
            const balance = await ethers.provider.getBalance(target)
            expect(balance).to.equals(100n * BigInt(1e18))
        })

        it("must deposit to target!", async () => {
            const address = await attacker.getAddress();
            console.log(address, "<<<");
            const contractSigner = await ethers.getSigner(address);

            await target.connect(contractSigner).deposit({ value: ethers.parseUnits("10", "gwei") });
        })



    })
});