// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/pyth-network/pyth-sdk-solidity/blob/main/IPyth.sol";
import "https://github.com/pyth-network/pyth-sdk-solidity/blob/main/PythStructs.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/entropy_sdk/solidity/IEntropy.sol";
import "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/entropy_sdk/solidity/IEntropyConsumer.sol";
