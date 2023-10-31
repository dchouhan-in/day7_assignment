import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { Assets, Coins } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";


describe("Main", function () {
    const tokenName = "NEW TOKEN"
    const tokenSymbol = "NTK"
    let coins: Coins
    let owner: HardhatEthersSigner
    let otherAccount: HardhatEthersSigner
    let otherAccount2: HardhatEthersSigner
    let ownerAddress: string
    let otherAccountAddress: string
    let otherAccount2Address: string


    describe("Coins", async function () {

        before("Deploy Contract!", async () => {
            [owner, otherAccount, otherAccount2] = await ethers.getSigners();

            ownerAddress = await owner.getAddress();
            otherAccountAddress = await otherAccount.getAddress();
            otherAccount2Address = await otherAccount2.getAddress();


            coins = await ethers.deployContract("Coins", [tokenName, tokenSymbol], owner);

            coinsAddress = await coins.getAddress()


            await coins.waitForDeployment();

            const ownerBalance = await coins.balanceOf(owner.address);

            expect(await coins.totalSupply()).to.equal(ownerBalance);

        });

        it("should have the correct name and symbol", async () => {
            const name = await coins.name();
            const symbol = await coins.symbol();
            expect(name).to.equal(tokenName)
            expect(symbol).to.equal(tokenSymbol)
        });

        it("should mint to another user!", async () => {
            const intialBal = await coins.balanceOf(otherAccount2Address);
            await coins.mint(otherAccount2Address, 1000);
            await coins.balanceOf(otherAccount2Address)
            const currentBal = await coins.balanceOf(otherAccount2Address);
            expect(intialBal + 10n ** 22n).to.equal(currentBal);
        });

        it("should have the correct total supply", async () => {
            const totalSupply = await coins.totalSupply();
            expect(totalSupply).to.equal(2n * 10n ** 22n)
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

    let assets: Assets


    describe("Assets", async function () {


        before("Deploy Contract!", async () => {

            assets = await ethers.deployContract("Assets", [coins.getAddress()], owner);

            await assets.waitForDeployment();

        });

        it("should have the correct balance!", async () => {
            const mintCount = 10;
            await assets.mint(mintCount);
            const balance = await assets.balanceOf(await owner.getAddress());
            expect(balance).to.equals(mintCount);

        })

        it("Should increase balance on further mint", async () => {

            const mintCount = 10;
            await assets.mint(mintCount);
            const balance = await assets.balanceOf(await owner.getAddress());

            expect(balance).to.equals(mintCount * 2);
        })

        it("Should return correct owner for asset!", async () => {

            const assetOwner = await assets.ownerOf(10);
            expect(assetOwner).to.equals(ownerAddress);
        })


        it("should set price of the asset!", async () => {

            const price = 10;
            const assetId = 0;
            await assets.setPrice(assetId, price)
            const assetPrice = await assets.getPrice(assetId)
            expect(assetPrice).to.equals(price);
        })

        it("should approve the user!", async () => {
            const approveToken = 9;
            await assets.approve(otherAccountAddress, approveToken);

            const approvee = await assets.getApproved(approveToken);
            expect(approvee).to.equals(await otherAccount.getAddress())
        })

        it("should transfer to another account!", async () => {
            const approveToken = 9;
            await assets.connect(otherAccount).transferFrom(ownerAddress, otherAccount2Address, approveToken);
            const balance = await assets.balanceOf(otherAccount2Address);
            expect(balance).to.equals(1);
        })

        it("should change owner of the asset!", async () => {

            const approveToken = 9;
            const tokenOwner = await assets.ownerOf(approveToken);
            expect(tokenOwner).to.equals(otherAccount2Address);
        })
    });


    describe("Swap Coins for Assets!", async function () {

        it("should change owner to coin contract!", async () => {
            const swapToken = 6;
            const price = 10;

            await assets.setPrice(swapToken, price)

            const ownerInitialBal = await assets.balanceOf(owner);

            await coins.approve(await assets.getAddress(), price);

            await assets.buy(swapToken);
            const balance = await assets.balanceOf(owner);

            const balanceOfContract = await coins.balanceOf(await assets.getAddress());
            const newOwner = await assets.ownerOf(swapToken);

            expect(balanceOfContract).to.equals(price);
            expect(balance).to.equals(ownerInitialBal);
            expect(newOwner).to.equals(ownerAddress);

        })

        it("should revert for unapproved buyers!", async () => {
            const swapToken = 7;
            const price = 2000;

            await coins.mint(otherAccountAddress, 1)

            await assets.setPrice(swapToken, price)


            await coins.connect(otherAccount).approve(await assets.getAddress(), price);


            expect(assets.connect(otherAccount).buy(swapToken)).to.be.reverted


        })

        it("should allow others to buy!", async () => {
            const swapToken = 7;
            const price = 2000;

            await coins.mint(otherAccountAddress, 1)

            await assets.setPrice(swapToken, price)

            const initialOwner = await assets.ownerOf(swapToken);

            await coins.connect(otherAccount).approve(await assets.getAddress(), price);

            await assets.approve(otherAccount, swapToken);

            await assets.connect(otherAccount).buy(swapToken)

            const newOwner = await assets.ownerOf(swapToken);
            expect(newOwner).to.not.equals(initialOwner)
            expect(newOwner).to.equals(otherAccountAddress)

        })

    })

})

