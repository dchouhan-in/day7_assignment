import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { network } from "hardhat";


const deployWeth: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {
    const { deploy } = hre.deployments;
    const { deployer } = await hre.getNamedAccounts();

    const weth: DeployResult = await deploy("WETH", {
        from: deployer,
        log: true,
        args: [],
        waitConfirmations: 6,
    });
};

export default deployWeth;
deployWeth.tags = ["all", "weth"];