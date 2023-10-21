import { getNamedAccounts,ethers } from "hardhat";


async function main() {

    const {deployer} = await getNamedAccounts();

    const sender = await ethers.getContract("Sender",deployer);
    console.log(sender);
    

    // @ts-ignore
    const tx = await sender.send(5,"0xdc99AfE5c8c7c08B301a93865B9e727f5A9Ee845","Polygon","aUSDC");
    console.log("Sending tokens...",tx.hash);
    tx.wait();

}


main().then(()=>{
    console.log("Token send from source chain successfull");
    process.exitCode = 0;
}).catch((error)=>{
    console.error(error);
    process.exitCode = 1;
})