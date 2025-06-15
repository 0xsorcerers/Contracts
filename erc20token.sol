// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract SoulOfSparta is ERC20 {
    constructor(string memory _name, string memory _symbol) public 
    ERC20(_name, _symbol)
    {
        mint();
    }

    function mint() public {
        _mint(msg.sender, 1000000000 * 1 ether); // Minting 100 trillion tokens to the deployer
    }
}
