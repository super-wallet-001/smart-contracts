//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';

contract DistributionExecutable is AxelarExecutable {
    IAxelarGasService public immutable gasService;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
    }

    function sendToMany(
        string memory destinationChain,
        string memory destinationAddress,
        address[] memory destinationAddresses,
        string memory symbol,
        uint256 amount
    ) public payable {
        require(msg.value > 0, 'Gas payment is required');

        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gateway), amount);
        bytes memory payload = abi.encode(destinationAddresses);
        gasService.payNativeGasForContractCallWithToken{ value: msg.value }(
            address(this),
            destinationChain,
            destinationAddress,
            payload,
            symbol,
            amount,
            msg.sender
        );
        gateway.callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        address[] memory recipients = abi.decode(payload, (address[]));
        address tokenAddress = gateway.tokenAddresses(tokenSymbol);

        uint256 sentAmount = amount / recipients.length;
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC20(tokenAddress).transfer(recipients[i], sentAmount);
        }
    }

    function sendTokensTest() public payable {
        string memory destinationChain = "optimism";
        string memory destinationAddress = "0xaA9E7B8D99EB2e5E4645b738397275dF0723f03E";

        address[] memory destinationAddresses = new address[](1);
        destinationAddresses[0] = 0xaA9E7B8D99EB2e5E4645b738397275dF0723f03E;

        string memory symbol = "aUSDC";
        uint256 amount  = 1;
        sendToMany(destinationChain, destinationAddress, destinationAddresses, symbol, amount) ;
    }
}
