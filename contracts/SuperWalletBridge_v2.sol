// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';


/**
 * @title Super bridge
 * @author https://github.com/sgerodes
 * @notice This contract was developed and need to be audited before production use
 */
contract SuperWalletBridge is AxelarExecutable {


    /**
     * State variables for the contract
     */
    mapping(address => bool) public isAdmin;
    address public owner;
    IAxelarGasService public immutable gasService;
    mapping(string => string) public bridgeAddresses;

    event AdminAdded(address indexed newAdmin);
    event AdminRemoved(address indexed oldAdmin);
    event Deposited(address indexed user, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, address indexed token, uint256 amount);
    event TokensExecuted(address indexed token, uint256 amount, address recipient);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Only admins can perform this action");
        _;
    }

    /**
     * @param gateway_ address of the axelar gateway
     * @param gasReceiver_ address of the gas receiver contract
     */
    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasService = IAxelarGasService(gasReceiver_);
        owner = msg.sender;
        isAdmin[owner] = true;
    }

    /**
     * To be executed by axelar gateway 
     */
    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        address recipient = abi.decode(payload, (address));
        address tokenAddress = gateway.tokenAddresses(tokenSymbol);
        IERC20(tokenAddress).transfer(recipient, amount);
        emit TokensExecuted(tokenAddress, amount, recipient);
    }

    /**
     * Send tokens to the specified address on the specified destination chain
     * @param destinationChain destination chain name 
     * @param destinationAddress recipient address on the destination chain
     * @param symbol token symbol to send
     * @param amount amount of tokens to send
     */
    function _sendTokens(
        string memory destinationChain,
        address destinationAddress,
        string memory symbol,
        uint256 amount
    ) public payable {
        string memory destinationChainBridgeAddress = bridgeAddresses[destinationChain];
        require(bytes(destinationChainBridgeAddress).length > 0, "The chain is not supported or the destination bridge is not set");

        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).approve(address(gateway), amount);
        bytes memory payload = abi.encode(destinationAddress);
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

    /**
     * Deposit tokens to the contract
     * @param tokenAmount address of the token to deposit
     * @param receiver address of the receiver on the destination chain
     * @param chain destination chain name
     * @param tokenSymbol symbol of the token to deposit
     */
    function send(
        uint256 tokenAmount,address receiver,string memory chain,string memory tokenSymbol
    ) external payable {
        require(msg.value > 0, 'Gas payment is required');
        uint256 contractBalance = IERC20(gateway.tokenAddresses(tokenSymbol)).balanceOf(address(this));
        require(contractBalance >= tokenAmount, 'Contract does not have enough tokens');
        _sendTokens(chain, receiver, tokenSymbol, tokenAmount);
    }

    /**
     * Add admin to the contract
     * @param _newAdmin address of the admin
     */
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

    ////////////////////////////////////////////Helper functions////////////////////////////////////////////
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
