import { expect } from "chai";
import { ethers } from "hardhat";


describe("Main", function () {
    const tokenName = "NEW TOKEN"
    const tokenSymbol = "NTK"
    let coins: any

    describe("Coins", async function () {
        const [owner, otherAccount, otherAccount2] = await ethers.getSigners();


        coins = await ethers.deployContract("Coins", [tokenName, tokenSymbol], owner);


        await coins.waitForDeployment();

        const ownerBalance = await coins.balanceOf(owner.address);

        expect(await coins.totalSupply()).to.equal(ownerBalance);

        it("should have the correct name and symbol", async () => {
            const name = await coins.name();
            const symbol = await coins.symbol();
            expect(name).to.equal(tokenName)
            expect(symbol).to.equal(tokenSymbol)
        });

        it("should have the correct total supply", async () => {
            const totalSupply = await coins.totalSupply();
            expect(totalSupply).to.equal(1000 * 10e18)
        });

        it("should have the correct decimals", async () => {
            const decimals = await coins.decimals();
            expect(decimals).to.equal(18)
        });

        // it("should mint tokens to the owner", async () => {
        //     await (await coins._mint(owner, 100)).wait()
        //     const balance = await coins.balanceOf(owner)
        //     expect(balance).equal(1100)
        // });

    });



    describe("Assets", async function () {

        const [owner, otherAccount, otherAccount2] = await ethers.getSigners();

        const assets = await ethers.deployContract("Assets", [coins.getAddress()], owner);

        await coins.waitForDeployment();

        const ownerBalance = await coins.balanceOf(owner.address);

        expect(await coins.totalSupply()).to.equal(ownerBalance);

    });

})

