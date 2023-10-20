import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";



const func: DeployFunction  = async function (hre: HardhatRuntimeEnvironment) {
    
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const {deployer} = await getNamedAccounts();

    const sender = await deploy("Sender", {
        from: deployer,
        args: ["0xC249632c2D40b9001FE907806902f63038B737Ab","0x57F1c63497AEe0bE305B8852b354CEc793da43bB"],
        log: true,
    });

    console.log("Sender deployed to:", sender.address);
    
};

export default func;
func.tags = ["Sender"];