// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.4.0/contracts/utils/ReentrancyGuard.sol";

contract BNB_Charitable_Donor_Society is ERC20, ReentrancyGuard {
    // A simple ERC20 token created with OpenZeppelin for best practices.
    constructor(string memory _name, string memory _symbol, address _czWallet, 
    address _giggleAcademyWallet, address _pancakeSwapRouter )
    ERC20(_name, _symbol)
    {
        authority[msg.sender] = true;
        authority[_czWallet] = true;
        authority[_giggleAcademyWallet] = true;
        ExcludeFromTransferFee[_pancakeSwapRouter] = true;
        ActiveCharities.push(_giggleAcademyWallet);
        donation = 200; // 0.2% donation to Giggle Academy
       _mint(msg.sender, 1000000000000 * 1 ether); // One-time mint of full supply of 1 trillion tokens to the deployer
    }

    bool public paused = false;

    modifier onlyAuthority() {
        require(authority[msg.sender], "Not authorized.");
        _;
    }    
    
    function setAuthority (address _newAuthority) external onlyAuthority nonReentrant {
        require(_newAuthority != address(0), "Invalid address.");
        if (!authority[_newAuthority]) {
            authority[_newAuthority] = true;
        } else {
            authority[_newAuthority] = false;
        }
    }  

    function setCharityAddresses (address[] calldata _newCharities) external onlyAuthority nonReentrant {
        ActiveCharities = _newCharities;
    }
    
    function excludeAddressFromFees (address _designee) external onlyAuthority nonReentrant {
        require(_designee != address(0), "Invalid address.");
        if (!ExcludeFromTransferFee[_designee]) {
            ExcludeFromTransferFee[_designee] = true;
        } else {
            ExcludeFromTransferFee[_designee] = false;
        }
    }

    /* The setDonation function is a percentage calculator to allow for donations 
    in micro percentages from 0.0001% to 0.1% for wider adoption and sustainability
    */
    function setDonation (uint256 _digits) external onlyAuthority nonReentrant {
        require(_digits > 0, "Not valid.");
        donation = _digits;
    }
    
    event Pause();
    function pause() external onlyAuthority nonReentrant {
        require(!paused, "Contract already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() external onlyAuthority nonReentrant {
        require(paused, "Contract not paused.");
        paused = false;
        emit Unpause();
    } 
    

}
