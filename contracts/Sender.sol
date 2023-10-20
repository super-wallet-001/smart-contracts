// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Sender {

    IAxelarGateway public immutable gateway;
    IERC20 public immutable token;

    constructor(address _gateway,address _token){
        gateway=IAxelarGateway(_gateway);
        token=IERC20(_token);
    }

    function send() public {
        // TODO: Transefer the tokens from msg.sender to self
        uint amount = 1 * 10 ** 6;
        token.approve(address(gateway),amount);
        gateway.sendToken(
            "Polygon",
            "0xdc99AfE5c8c7c08B301a93865B9e727f5A9Ee845",
            "aUSDC",
            amount
        );
    }

}