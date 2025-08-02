// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.4.0/contracts/token/ERC20/ERC20.sol";

contract SoulOfSparta is ERC20 {
    // A simple ERC20 token created with OpenZeppelin for best practices.
    constructor(string memory _name, string memory _symbol) public 
    ERC20(_name, _symbol)
    {
       _mint(msg.sender, 1000000000000 * 1 ether); // One-time mint of full supply of 1 trillion tokens to the deployer
    }

}
