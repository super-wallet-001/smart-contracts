// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';

contract SuperWalletBridge is AxelarExecutable {
    mapping(address => bool) public isAdmin;
    address public owner;
    IAxelarGasService public immutable gasService;
    mapping(string => string) public bridgeAddresses;

    event AdminAdded(address indexed newAdmin);
    event AdminRemoved(address indexed oldAdmin);
    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount);
    event TokensExecuted(address indexed token, uint256 amount, address[] recipients);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Only admins can perform this action");
        _;
    }

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
        owner = msg.sender;
        isAdmin[owner] = true;
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
        emit TokensExecuted(tokenAddress, amount, recipients);
    }


    function _sendTokens(
        string memory destinationChain,
        address[] memory destinationAddresses,
        string memory symbol,
        uint256 amount
    ) public payable {
        string memory destinationChainBridgeAddress = bridgeAddresses[destinationChain];
        require(bytes(destinationChainBridgeAddress).length > 0, "The chain is not supported or the destination bridge is not set");

        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).approve(address(gateway), amount);
        bytes memory payload = abi.encode(destinationAddresses);
        gasService.payNativeGasForContractCallWithToken{ value: msg.value }(
            address(this),
            destinationChain,
            destinationChainBridgeAddress,
            payload,
            symbol,
            amount,
            msg.sender
        );
        gateway.callContractWithToken(destinationChain, destinationChainBridgeAddress, payload, symbol, amount);
    }

    function sendTokens(
        string memory destinationChain,
        string memory symbol,
        uint256 amount
    ) external payable {

        require(msg.value > 0, 'Gas payment is required');
        uint256 contractBalance = IERC20(gateway.tokenAddresses(symbol)).balanceOf(address(this));
        require(contractBalance >= amount, 'Contract does not have enough tokens');

        address[] memory destinationAddresses = new address[](1);
        destinationAddresses[0] = msg.sender;

        _sendTokens(destinationChain, destinationAddresses, symbol, amount);
    }

    function addAdmin(address _newAdmin) external onlyOwner {
        require(!isAdmin[_newAdmin], "Address is already an admin");
        isAdmin[_newAdmin] = true;
        emit AdminAdded(_newAdmin);
    }

    function removeAdmin(address _adminToRemove) external onlyOwner {
        require(isAdmin[_adminToRemove], "Address is not an admin");
        isAdmin[_adminToRemove] = false;
        emit AdminRemoved(_adminToRemove);
    }

    function adminTransfer(address token, address recipient, uint256 amount) external onlyAdmin {
        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient contract balance");
        require(IERC20(token).transfer(recipient, amount), "Transfer failed");
    }

    function adminTransferBase(address payable recipient, uint256 amount) external onlyAdmin {
        require(address(this).balance >= amount, "Insufficient contract balance");
        recipient.transfer(amount);
    }

    function setBridgeAddress(string calldata chainName, string memory contractAddress) external onlyOwner {
        bridgeAddresses[chainName] = contractAddress;
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
