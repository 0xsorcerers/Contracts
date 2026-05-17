// SPDX-License-Identifier: MIT
//Penny4Thots Rewards System

pragma solidity 0.8.21;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.4.0/contracts/utils/ReentrancyGuard.sol";
import "contracts/contracts/taxableInternalERC20.sol";

contract Penny is ERC20, ReentrancyGuard {}
