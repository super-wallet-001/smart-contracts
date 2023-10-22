import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";



const func: DeployFunction  = async function (hre: HardhatRuntimeEnvironment) {
    
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const {deployer} = await getNamedAccounts();
    const {chainId} = await ethers.provider.getNetwork();

    // console.log((chainId).toString());

    const chainIdStr  = (chainId).toString();
    let gateWay;
    let gasReceiver;
    if(chainIdStr==="80001"){
        gateWay="0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B";
        gasReceiver="0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B"
    }else if(chainIdStr==="43113"){
        gateWay="0xC249632c2D40b9001FE907806902f63038B737Ab";
        gasReceiver="0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6"
    }else if(chainIdStr==="534351"){
        gateWay="0xe432150cce91c13a887f7D836923d5597adD8E31";
        gasReceiver="0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6"
    }else if(chainIdStr=="5001"){
        gateWay="0xe432150cce91c13a887f7D836923d5597adD8E31";
        gasReceiver="0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";
    }
    
    const SuperWalletBridge_v2 = await deploy("SuperWalletBridge_v2", {
        from: deployer,
        args: ["",""],
        log: true,
    });

    console.log("SuperWalletBridge_v2 deployed to:", SuperWalletBridge_v2.address);
    
};

export default func;
func.tags = ["Bridge_v2"];