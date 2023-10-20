import { getNamedAccounts,ethers } from "hardhat";


async function main() {

    const {deployer} = await getNamedAccounts();

    const sender = await ethers.getContract("Sender",deployer);
    console.log(sender);
    

    // @ts-ignore
    const tx = await sender.send();
    console.log("Sending tokens...",tx);
    tx.wait();

}


main().then(()=>{
    console.log("Token send from source chain successfull");
    process.exitCode = 0;
}).catch((error)=>{
    console.error(error);
    process.exitCode = 1;
})