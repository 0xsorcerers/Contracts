// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

interface IMatchBet {
    function balanceOf(address _sender) external view returns (uint256);
    function ownerOf(uint256 _index) external view returns (address);
    function blacklisted(uint256 _index) external view returns (bool);
}
