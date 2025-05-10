// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/sdk/solidity/IPyth.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/entropy_sdk/solidity/IEntropy.sol";
import "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/entropy_sdk/solidity/IEntropyConsumer.sol";

interface ITalesOfSparta {
    function balanceOf(address _sender) external view returns (uint256);
    function ownerOf(uint256 _index) external view returns (address);
    function blacklisted(uint256 _index) external view returns (bool);
}

contract LegendOfSparta is ReentrancyGuard, IEntropyConsumer {

    constructor(address _pyth, address _spartanDAO, address _talesOfSparta, uint256 _feeInWei, 
    bytes32 _sonicPriceId, address _entropy, address _entropyProvider) {
        pyth = IPyth(_pyth);
        sonicPriceId = _sonicPriceId;
        spartanDAO = _spartanDAO;
        talesOfSparta = _talesOfSparta;
        fee = _feeInWei;
        entropy = IEntropy(_entropy);
        entropyProvider = _entropyProvider;
    }
    
    event proofOfLegend(uint256 indexed id, address indexed from, uint256 indexed amountWon, uint256 seeded);
    event proofOfNumber(address indexed from, bytes32 number, uint256 proof);
    event RandomNumberRequest(bytes32 indexed userRandomNumber, address indexed sender, uint64 indexed sequenceNumber);
    event RandomNumberResult(uint64 sequenceNumber, uint8 result);

    IEntropy private entropy;
    address private entropyProvider;
    IPyth pyth;
    bytes32 sonicPriceId;

    address public spartanDAO; 
    address public burnAddress; 
    address public bobbAddress;
    address public talesOfSparta;
    address private developmentAddress;
    uint256 public fee;
    uint256 public reseed = 10;
    uint256 public multiple = 2;
    uint256 public sosMultiple = 1000000;
    uint256 public age = 120;
    uint256 private challengers = 18;
    uint256 public payId = 0;
    uint256 public burntoll = 10;
    uint256 public deadtax = 0;
    uint256 public devtax = 0;
    uint256 public platformFee = 10;
    uint256 public TotalBurns = 0;
    uint256 public TotalPlays = 0;
    uint256 public era = 1;
    uint256 public TotalAmountWon = 0;
    string public Author = "undoxxed";
    bool public feeType = true; 
    bool public paused = false; 

    modifier onlySpartanDAO() {
        require(msg.sender == spartanDAO, "Not authorized.");
        _;
    }

    struct TokenInfo {
        IERC20 paytoken;
    }

    struct LegendInfo {
        uint8 indexer;
        address caller;
        uint256 platformFee;
    }

    struct WinnersList {
        address winner;
        uint256 era;
        uint256 amount;
        uint256 timestamp;
    }

    struct BlackList {
        bool blacklist;       
    }

    //Array
    TokenInfo[] public AllowedCrypto;

    //Maps
    mapping (uint256 => BlackList) public blacklisted;
    mapping (uint256 => WinnersList) public pastwinners;
    mapping (uint256 => LegendInfo) private legendary;
    
    function addCurrency(IERC20 _paytoken) external onlySpartanDAO {
        AllowedCrypto.push(
            TokenInfo({
                paytoken: _paytoken
            })
        );
    }

    function getTalesOfSparta(uint256 _tokenId) internal view returns (uint256) {
        bool taleState = ITalesOfSparta(talesOfSparta).blacklisted(_tokenId);
        if (!taleState) {
            address taleOwner = ITalesOfSparta(talesOfSparta).ownerOf(_tokenId);
            if (taleOwner == msg.sender) {
                return _tokenId;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    
    function requestRandomNumber() internal view returns (uint8) {
        // Convert the random number to uint256
        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp)));
        
        // Calculate the result between 1 and 18
        uint8 result = uint8((randomValue % challengers) + 1);
        return result;
    }      

    // Get the fee for requesting a random number
    function getRequestFee() public view returns (uint256 fee_) {
        fee_ = entropy.getFee(entropyProvider);
    }

    // Callback function called by entropy with the random number
    function entropyCallback(
        uint64 sequenceNumber,
        address,
        bytes32 randomNumber
    ) internal override {
        // Convert the random number to uint256
        uint256 randomValue = uint256(randomNumber);
        
        // Calculate the result between 1 and 18
        uint8 result = uint8((randomValue % challengers) + 1);
        
        emit RandomNumberResult(sequenceNumber, result);

        if (legendary[sequenceNumber].indexer == result) {
            address winner = legendary[sequenceNumber].caller; 
            uint256 balance = address(this).balance;
            if (balance > 0) {
                uint256 seed = (balance * reseed) / 100;
                uint256 amountWon = balance - seed;
                uint256 winfee = (amountWon * legendary[sequenceNumber].platformFee) / 100;
                uint256 amountPayable = amountWon - winfee;
                payable(winner).transfer(amountPayable);
                payable(developmentAddress).transfer(winfee); 
                pastwinners[era].era = era;
                pastwinners[era].winner = msg.sender;
                pastwinners[era].amount = amountWon;
                pastwinners[era].timestamp = block.timestamp;
                TotalAmountWon += amountWon;
                era++;
                emit proofOfLegend(era, msg.sender, amountWon, seed);
            }
        }
    }

    // Required by IEntropyConsumer interface
    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    receive() external payable {}
    
    function sendToLegend(uint256 _tale, bytes32 userRandomNumber, bytes[] calldata updateData) public payable nonReentrant { 
        require(!paused, "Paused Contract");
        uint256 tokenId = getTalesOfSparta(_tale);
        uint8 _index = requestRandomNumber();
        emit proofOfNumber(msg.sender, userRandomNumber, _index);

        uint amountWei;
        uint256 platformfee;

        // call entropy oracle
        uint256 _fee = entropy.getFee(entropyProvider);
        uint updateFee = pyth.getUpdateFee(updateData);
        pyth.updatePriceFeeds{value: updateFee}(updateData);

        PythStructs.Price memory currentSonicPrice = pyth.getPriceNoOlderThan(sonicPriceId, age);

        require(currentSonicPrice.price >= 0, "Price should be positive.");

        int32 totalSonicExpo = currentSonicPrice.expo + 18;

        if (totalSonicExpo >= 0) {
            // Divide by (price * 10^totalSonicExpo)
            amountWei = (fee * 1e18) / (uint(uint64(currentSonicPrice.price)) * (10 ** uint32(totalSonicExpo)));
        } else {
            // If totalSonicExpo is negative (unlikely since expo is usually -7 to +7), 
            // multiply by 10^|totalSonicExpo| (but this case shouldn't happen with typical expo values)
            amountWei = (fee * 1e18 * (10 ** uint32(-totalSonicExpo))) / uint(uint64(currentSonicPrice.price));
        }
    
        //TOS NFT Checker
        if (tokenId > 0) {
            //LOGIC FOR TALES OF SPARTA OWNER
            // transfer S needed for gameplay
            require (msg.value - updateFee - _fee >= amountWei, "Insufficient fee");
            platformfee = platformFee; 
            uint256 excess = msg.value - amountWei - updateFee - _fee;
            if (excess > 0) {
            payable(msg.sender).transfer(excess);
            }

        } else {
            // LOGIC FOR SOS HOLDERS
            if (feeType) {
                // Require S needed for gameplay
                uint256 totalFees = updateFee + _fee;
                require (msg.value - totalFees >= amountWei, "Insufficient fee");  
                // Transfer multiples of SOS for required deposit and burn is required
                uint256 requiredAmount = amountWei * sosMultiple;
                transferTokens(requiredAmount); 
                //Initiate a pecentage burn from the contract       
                burn(requiredAmount, burntoll);    
                platformfee = platformFee * 2;      
                uint256 excess = msg.value - (amountWei + totalFees);
                // return excess funds
                if (excess > 0) {
                    payable(msg.sender).transfer(excess);
                }

            } else {
                // Require multiple of S need for gameplay
                uint256 requiredAmount = amountWei * multiple;
                uint256 totalFees = updateFee + _fee;
                require(msg.value - totalFees >= requiredAmount, "Insufficient fee");
                
                // Transfer extra amount to bobbAddress
                payable(bobbAddress).transfer(requiredAmount - amountWei);

                platformfee = platformFee * 2;
                
                // Return Excess funds
                uint256 excess = msg.value - (requiredAmount + totalFees);
                if (excess > 0) {
                    payable(msg.sender).transfer(excess);
                }
            }
        }

        uint64 sequenceNumber = entropy.requestWithCallback{value: fee}(
            entropyProvider,
            userRandomNumber
        );

        legendary[sequenceNumber].caller = msg.sender;
        legendary[sequenceNumber].indexer = _index;
        legendary[sequenceNumber].platformFee = platformfee;
        TotalPlays++;

        emit RandomNumberRequest(userRandomNumber, msg.sender, sequenceNumber);

    }

    function burn(uint256 _burnAmount, uint256 _num) internal {
        uint256 taxed = (_burnAmount * _num)/100 ;

        uint256 dead = (taxed * deadtax)/100;
        uint256 dev =  (taxed * devtax)/100;

        TokenInfo storage tokens = AllowedCrypto[payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;               
        paytoken.transfer(burnAddress, dead);   
        paytoken.transfer(developmentAddress, dev); 
        TotalBurns += dead;       
    }
    
    function transferTokens(uint256 _cost) internal {
        TokenInfo storage tokens = AllowedCrypto[payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transferFrom(msg.sender,address(this), _cost);
    } 

    function setProviders (address _pyth, bytes32 _sonicPriceId, address _entropy, address _entropyProvider) external onlySpartanDAO {
        pyth = IPyth(_pyth);
        sonicPriceId = _sonicPriceId;
        entropy = IEntropy(_entropy);
        entropyProvider = _entropyProvider;
    }

    function setValues (uint256 _feeInWei, uint256 _age, uint256 _challengers, uint256 _payId, uint256[] calldata _taxes) external onlySpartanDAO() {
        fee = _feeInWei;
        age = _age;
        challengers = _challengers;
        payId = _payId;
        burntoll = _taxes[0];
        deadtax = _taxes[1];
        devtax = _taxes[2];
        reseed = _taxes[3];
        platformFee = _taxes[4];
        multiple = _taxes[5];
        sosMultiple = _taxes[6];
    } 
    
    function setAddresses (address _burnAddress, address _bobbAddress, address _devAddress,address _talesOfSparta) external onlySpartanDAO {
        burnAddress = _burnAddress;
        bobbAddress = _bobbAddress;
        developmentAddress = _devAddress;
        talesOfSparta = _talesOfSparta;
    }

    function setFeeType(uint _binary) external onlySpartanDAO {
        if (_binary > 0) {
            feeType = true;
        } else {
            feeType = false;
        }
    }
    
    function setAuthor (string memory _reveal) external onlySpartanDAO {
        Author = _reveal;
    }

    function withdraw(uint256 _amount) external payable onlySpartanDAO nonReentrant {
        address payable _owner = payable(spartanDAO);
        _owner.transfer(_amount);
    }

    function withdrawERC20(uint256 _payId, uint256 _amount) external payable onlySpartanDAO nonReentrant {
        TokenInfo storage tokens = AllowedCrypto[_payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transfer(msg.sender, _amount);
    }

    event Pause();
    function pause() public onlySpartanDAO {
        require(!paused, "Already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() public onlySpartanDAO {
        require(paused, "Not paused.");
        paused = false;
        emit Unpause();
    } 

    function setDAO (address _spartanDAO) external onlySpartanDAO {
        spartanDAO = _spartanDAO;
    }

}
