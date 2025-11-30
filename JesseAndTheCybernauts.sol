// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import { IEntropyV2 } from "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/entropy_sdk/solidity/IEntropyV2.sol";
import { IEntropyConsumer } from "https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/ethereum/entropy_sdk/solidity/IEntropyConsumer.sol";

interface ICybernaut {
    function balanceOf(address _sender) external view returns (uint256);
    function ownerOf(uint256 _index) external view returns (address);
    function blacklisted(uint256 _index) external view returns (bool);
}

interface IFarm {
    function balanceOf(address _sender) external view returns (uint256);
}

contract JesseAndTheCybernauts is ReentrancyGuard, IEntropyConsumer {
    constructor(
        address _cyberneticDAO,
        address _entropy
    ) {
        cyberneticDAO = _cyberneticDAO;
        entropy = IEntropyV2(_entropy);
        lastAddress = _cyberneticDAO;
    }

    event proofOfCyber(
        uint256 indexed id,
        address indexed from,
        uint256 indexed amountWon,
        uint256 seeded
    );
    event proofOfNumber(address indexed from, bytes32 number, uint256 proof);
    
    event RandomNumberRequest(
        bytes32 indexed userRandomNumber,
        address indexed sender,
        uint64 indexed sequenceNumber
    );
    event RandomNumberResult(uint64 sequenceNumber, uint8 result);

    IEntropyV2 private entropy;

    address public cybernaut;
    address public cyberneticDAO;
    address public burnAddress;
    address public bobbAddress;
    address public stakeAddress;
    address private developmentAddress;
    address private lastAddress;
    uint256 public reseed = 10;
    uint256 public multiple = 2;
    uint256 public requiredFee = 2500 ether;
    uint256 public age = 120;
    uint256 private challengers = 18;
    uint256 public payId = 0;
    uint256 public burntoll = 100;
    uint256 public deadtax = 0;
    uint256 public bobbtax = 0;
    uint256 public staketax = 0;
    uint256 public lasttax = 0;
    uint256 public devtax = 0;
    uint256 public platformFee = 20;
    uint256 public TotalBurns = 0;
    uint256 public TotalStaked = 0;
    uint256 public TotalPaid = 0;
    uint256 public TotalReserved = 0;
    uint256 public TotalPromos = 0;
    uint256 public TotalPlays = 0;
    uint256 public era = 1;
    uint256 public TotalAmountWon = 0;
    string public Author = "undoxxed";
    bool public paused = false;

    modifier onlyCyberneticDAO() {
        require(msg.sender == cyberneticDAO, "Not authorized.");
        _;
    }

    struct TokenInfo {
        IERC20 paytoken;
    }

    struct CyberInfo {
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
    address [] public AllowedCurrencies;
    address[] public AllowedFarms;
    uint256[] public AllowedAmounts;
    uint256[] public permittedFarms;

    //Maps
    mapping(uint256 => WinnersList) public pastwinners;
    mapping(uint64 => CyberInfo) private cybermorphy; 
    mapping(address => uint256) public TokensDistributed;
    mapping (uint256 => uint256) public powerIndex;

    function addCurrency(address _paytoken) external onlyCyberneticDAO {
        IERC20 payToken = IERC20(_paytoken);
        AllowedCrypto.push(TokenInfo({paytoken: payToken}));
        AllowedCurrencies.push(_paytoken);
    }

    function getCybernaut(uint256 _tokenId) internal view returns (uint256) {
        bool nftState = ICybernaut(cybernaut).blacklisted(_tokenId);
        if (!nftState) {
            address nftOwner = ICybernaut(cybernaut).ownerOf(_tokenId);
            if (nftOwner == msg.sender) {
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
        uint256 randomValue = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.timestamp, msg.sender)
            )
        );

        // Calculate the result between 1 and challengers
        uint8 result = uint8((randomValue % challengers) + 1);
        return result;
    }

    // Get the fee for requesting a random number (V2 returns uint128 in the SDK)
    function getRequestFee() public view returns (uint256 fee_) {
        uint128 f = entropy.getFeeV2();
        fee_ = uint256(f);
    }

    // Callback function called by entropy with the random number
    function entropyCallback(
        uint64 sequenceNumber,
        address /* providerAddress */,
        bytes32 randomNumber
    ) internal override {
        // Convert the random number to uint256
        uint256 randomValue = uint256(randomNumber);

        // Calculate the result between 1 and challengers
        uint8 result = uint8((randomValue % challengers) + 1);

        emit RandomNumberResult(sequenceNumber, result);

        // Verify mapping by the sequence number
        CyberInfo memory info = cybermorphy[sequenceNumber];

        if (info.indexer == result) {
            address winner = info.caller;
            TokenInfo storage tokens = AllowedCrypto[payId];
            IERC20 paytoken = tokens.paytoken;
            address currency = AllowedCurrencies[payId];
            uint256 balance = IFarm(currency).balanceOf(address(this));

            if (balance > 0) {
                uint256 seed = (balance * reseed) / 100;
                uint256 amountWon = balance - seed;
                uint256 winfee = (amountWon * info.platformFee) / 100;
                uint256 amountPayable = amountWon - winfee;

                // Transfer payouts
                paytoken.transfer(winner, amountPayable);
                paytoken.transfer(developmentAddress, winfee);

                // Save past winner using the current era (before increment)
                uint256 currentEra = era;
                pastwinners[currentEra].era = currentEra;
                pastwinners[currentEra].winner = winner;
                pastwinners[currentEra].amount = amountWon;
                pastwinners[currentEra].timestamp = block.timestamp;
                TotalAmountWon += amountWon;

                // increment era AFTER storing winner
                era++;

                emit proofOfCyber(currentEra, winner, amountWon, seed);
            }
        }
    }

    // Required by IEntropyConsumer interface
    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    receive() external payable {}

    uint256 public tokenIndicator;

    function sendToCyber(
        uint256 _nft,
        bytes32 userRandomNumber
    ) public payable nonReentrant {
        require(!paused, "Paused Contract");
        uint256 tokenId = getCybernaut(_nft);
        uint8 _index = requestRandomNumber();
        emit proofOfNumber(msg.sender, userRandomNumber, _index);

        uint256 platformfee;

        // call entropy oracle (V2)
        uint256 _fee = uint256(entropy.getFeeV2());
        require(msg.value >= _fee, "Insufficient fee");

        // //Cybernaut NFT Checker
        if (tokenId > 0) {
            // Transfer multiples of jesse for required deposit and burn is required
            transferTokens(requiredFee);
            // Initiate redistribution from the contract
            burn(requiredFee, burntoll);

            platformfee = platformFee - powerIndex[tokenId];

        } else {

            uint256 requiredFees = requiredFee * multiple;
            // Transfer multiples of jesse for required deposit and burn
            transferTokens(requiredFees);
            burn(requiredFees, burntoll);

            platformfee = platformFee + 5;

        }


        uint64 sequenceNumber = entropy.requestV2{value: _fee}();

        // accept donations for development (excess paid over fee)
        uint256 excess = msg.value - _fee;
        if (excess > 0) {
            payable(developmentAddress).transfer(excess);
        }

        cybermorphy[sequenceNumber].caller = msg.sender;
        cybermorphy[sequenceNumber].indexer = _index;
        cybermorphy[sequenceNumber].platformFee = platformfee;
        lastAddress = msg.sender;
        TotalPlays++;

        //distribute incentive promos
        promoDistribution();

        emit RandomNumberRequest(userRandomNumber, msg.sender, sequenceNumber);
    }

    function AddToFarmReorg(
        uint256 _farmInWei,
        address _token,
        uint256[] calldata _permittedFarms
    ) external onlyCyberneticDAO {
        uint256 farming = _farmInWei;
        IERC20 farmtoken = IERC20(_token);
        farmtoken.transferFrom(msg.sender, address(this), farming);
        permittedFarms = _permittedFarms;
    }

    function promoDistribution() internal {
        if (AllowedFarms.length > 0) {
            for (uint256 f = 0; f < permittedFarms.length; f++) {
                uint256 indexFarm = permittedFarms[f];
                address currentFarm = AllowedFarms[indexFarm];
                IERC20 farmtoken = IERC20(currentFarm);
                uint256 farmbal = IFarm(currentFarm).balanceOf(address(this));
                uint256 farm = AllowedAmounts[indexFarm];
                if (farmbal > farm && farm > 0) {
                    farmtoken.transfer(lastAddress, farm);
                    TokensDistributed[currentFarm] += farm;
                    TotalPromos += farm;
                }
            }
        }
    }

    function burn(uint256 _burnAmount, uint256 _num) internal {
        uint256 taxed = (_burnAmount * _num) / 100;

        uint256 dead = (taxed * deadtax) / 100;
        uint256 bobb = (taxed * bobbtax) / 100;
        uint256 stake = (taxed * staketax) / 100;
        uint256 last = (taxed * lasttax) / 100;
        uint256 dev = (taxed * devtax) / 100;

        TokenInfo storage tokens = AllowedCrypto[payId];
        IERC20 paytoken = tokens.paytoken;
        paytoken.transfer(burnAddress, dead);
        paytoken.transfer(bobbAddress, bobb);
        paytoken.transfer(stakeAddress, stake);
        paytoken.transfer(lastAddress, last);
        paytoken.transfer(developmentAddress, dev);
        
        TotalReserved += bobb;
        TotalStaked += stake;
        TotalPaid += last;
        TotalBurns += dead;
    }

    function transferTokens(uint256 _cost) internal {
        TokenInfo storage tokens = AllowedCrypto[payId];
        IERC20 paytoken = tokens.paytoken;
        paytoken.transferFrom(msg.sender, address(this), _cost);
    }

    function setProviders(
        address _entropy
    ) external onlyCyberneticDAO {
        entropy = IEntropyV2(_entropy);
    }

    function setValues(
        uint256 _challengers,
        uint256 _payId,
        uint256[] calldata _taxes
    ) external onlyCyberneticDAO {
        challengers = _challengers;
        payId = _payId;
        burntoll = _taxes[0];
        deadtax = _taxes[1];
        bobbtax = _taxes[2];
        staketax = _taxes[3];
        lasttax = _taxes[4];
        devtax = _taxes[5];
        reseed = _taxes[6];
        platformFee = _taxes[7];
        multiple = _taxes[8];
        requiredFee = _taxes[9];
    }

    function setAddresses(
        address _burnAddress,
        address _bobbAddress,
        address _stakeAddress,
        address _devAddress,
        address _cybernaut
    ) external onlyCyberneticDAO {
        burnAddress = _burnAddress;
        bobbAddress = _bobbAddress;
        developmentAddress = _devAddress;
        stakeAddress = _stakeAddress;
        cybernaut = _cybernaut;
    }

    function setFarmYield(
        address[] memory _allowedFarms,
        uint256[] memory _farmingAmounts,
        uint256[] memory _permittedFarms
    ) external onlyCyberneticDAO {
        permittedFarms = _permittedFarms;
        AllowedAmounts = _farmingAmounts;
        AllowedFarms = _allowedFarms;
    }

    function addToPowerIndex(uint256 _start, uint256[] calldata _indices) external onlyCyberneticDAO {
        for (uint256 i = 0; i < _indices.length; i++) {
            powerIndex[_start + i] = _indices[i];
        }
    }

    function setAuthor(string memory _reveal) external onlyCyberneticDAO {
        Author = _reveal;
    }

    function withdraw(
        uint256 _amount
    ) external payable onlyCyberneticDAO nonReentrant {
        address payable _owner = payable(cyberneticDAO);
        _owner.transfer(_amount);
    }

    function withdrawERC20(
        address _token,
        uint256 _amount
    ) external payable onlyCyberneticDAO nonReentrant {
        IERC20 paytoken = IERC20(_token);
        paytoken.transfer(msg.sender, _amount);
    }

    event Pause();
    function pause() public onlyCyberneticDAO {
        require(!paused, "Already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() public onlyCyberneticDAO {
        require(paused, "Not paused.");
        paused = false;
        emit Unpause();
    }

    function setDAO(address _cyberneticDAO) external onlyCyberneticDAO {
        cyberneticDAO = _cyberneticDAO;
    }
}
