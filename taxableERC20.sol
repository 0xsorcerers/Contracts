// SPDX-License-Identifier: MIT
//Penny4Thots Rewards System

pragma solidity 0.8.21;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.4.0/contracts/utils/ReentrancyGuard.sol";
import "contracts/contracts/taxableInternalERC20.sol";

contract Penny is ERC20, ReentrancyGuard {
    // A simple ERC20 token created with OpenZeppelin for best practices.
    constructor(string memory _name, string memory _symbol, address _pennyDAO, address _devWallet, address _lpWallet, 
    address _deadWallet, uint256 _penalty) public 
    ERC20(_name, _symbol)
    {
        pennyDAO = _pennyDAO;
        devWallet = _devWallet;
        lpWallet = _lpWallet;
        deadWallet = _deadWallet;
        penalty = _penalty;
       _mint(msg.sender, 10_000_000 * 1 ether); // One-time mint of full supply of 1 trillion tokens to the deployer
    }

    modifier onlyPennyDAO() {
        require(msg.sender == pennyDAO, "Not authorized.");
        _;
    }

    address public pennyDAO;

    function mint(uint256 _amount) external nonReentrant onlyPennyDAO {
       _mint(msg.sender, _amount * 1 ether); 
    }


}
