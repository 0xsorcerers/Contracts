
// File: contracts/MatchCards.sol
// Custom contract
// @title MatchBet GambleFi
// Match Bet Player Cards on Matchain 
// website: https://matchbet.my | telegram: https://t.me/matchbet | twitter: https://x.com/matchbet

contract MatchBetCards is ERC721Enumerable, Ownable, ReentrancyGuard {        
        constructor(string memory _name, string memory _symbol, address _matchBetDAO) 
            ERC721(_name, _symbol)
        {
            matchBetDAO = _matchBetDAO;
        }  
    using SafeERC20 for IERC20;  
    using Strings for uint256;
    
    address public matchBetDAO; 
    address private developmentAddress;
    address public burnAddress;
    string public baseURI;
    uint256 public fee = 100 ether;
    uint256 public tokenFee = 0 ether;
    uint256 public payId = 0;
    uint256 public immutable supplyCap = 5000;
    uint256 private startTime = block.timestamp + 1 weeks;
    uint256 private wlDuration = 60 minutes;
    uint256 public toll = 100;
    uint256 public deadtax = 0;
    uint256 public devtax = 0;
    uint256 public TotalBurns = 0;
    uint256 public LIST2Limit = 100;
    uint256 public LIST3Limit = 100;
    uint256 public LIST1Limit = 100;
    uint256 public LIST5Limit = 100;
    uint256 public LIST4Limit = 70;
    uint256 public contributorLimit = 30;
    string public Author = "undoxxed";
    bool public baseURItype = false; 
    bool public paused = false; 

    modifier onlyMatchBetDAO() {
        require(msg.sender == matchBetDAO, "Not authorized.");
        _;
    }

    struct TokenInfo {
        IERC20 paytoken;
    }

    struct WhiteList {
        bool whitelist;
        uint256 LIST1owner;
        uint256 LIST3owner;
        uint256 LIST2owner;
        uint256 LIST4Community;
        uint256 LIST5Contributor;
        uint256 earlyContributor;
    }

    struct BlackList {
        bool blacklist;    
    }

    struct CardsMinted {
        uint256 cardsmint;
        uint256 LIST1mints;
        uint256 LIST3mints;
        uint256 LIST2mints;
        uint256 LIST4Mints;
        uint256 LIST5Mints;
        uint256 contributorMints;
    }

    //Array
    TokenInfo[] public AllowedCrypto;

    //Maps
    mapping (address => WhiteList) public whitelisted;
    mapping (uint256 => BlackList) public blacklisted;
    mapping (address => CardsMinted) public cardsminted;
    
    function addCurrency(IERC20 _paytoken) external onlyMatchBetDAO {
        AllowedCrypto.push(
            TokenInfo({
                paytoken: _paytoken
            })
        );
    }

    function whitelistState() internal returns (bool) {
        if (!whitelisted[msg.sender].whitelist) return false;     
        uint256 cardsUnminted = totalMintable();   
        if (cardsUnminted > 0 && limitCompliance()) {
            return true;
        } 
        return false;        
    }

    function totalMintable() internal view returns (uint256) {
        uint256 cardsOwned = cardsminted[msg.sender].cardsmint;
        uint256 cardsMintable = whitelisted[msg.sender].LIST1owner + whitelisted[msg.sender].LIST3owner + whitelisted[msg.sender].LIST2owner 
            + whitelisted[msg.sender].LIST4Community + whitelisted[msg.sender].LIST5Contributor + whitelisted[msg.sender].earlyContributor;
        uint256 cardsUnminted = cardsMintable - cardsOwned;
          require(cardsOwned <= cardsMintable, "failsafe");
        return cardsUnminted;
    }

    function limitCompliance() internal returns (bool) {
        if (cardsminted[msg.sender].cardsmint < 1) {          
            // initialize snapshot record of cardsMint
        cardsminted[msg.sender].LIST1mints = whitelisted[msg.sender].LIST1owner;
        cardsminted[msg.sender].LIST3mints = whitelisted[msg.sender].LIST3owner;
        cardsminted[msg.sender].LIST2mints = whitelisted[msg.sender].LIST2owner;
        cardsminted[msg.sender].LIST4Mints = whitelisted[msg.sender].LIST4Community;
        cardsminted[msg.sender].LIST5Mints = whitelisted[msg.sender].LIST5Contributor;
        cardsminted[msg.sender].contributorMints = whitelisted[msg.sender].earlyContributor;
        } 

            //Objectively subtract mint from associated whitelist limit
            if (cardsminted[msg.sender].LIST1mints > 0 && LIST1Limit > 0) {
                cardsminted[msg.sender].LIST1mints--;
                // subtract mint from LIST1 eligibilty whitelist
                LIST1Limit--;
                return true;
            } else if (cardsminted[msg.sender].LIST3mints > 0 && LIST3Limit > 0) {
                cardsminted[msg.sender].LIST3mints--;
                // subtract mint from LIST3 eligibility whitelist
                LIST3Limit--;
                return true;
            } else if (cardsminted[msg.sender].LIST2mints > 0 && LIST2Limit > 0) {
                cardsminted[msg.sender].LIST2mints--;
                //subtract mint from LIST2 eligibility whitelist
                LIST2Limit--;
                return true;
            } else if (cardsminted[msg.sender].LIST4Mints > 0 && LIST4Limit > 0) {
                cardsminted[msg.sender].LIST4Mints--;
                // subtract mint from LIST4 eligibility whitelist
                LIST4Limit--;
                return true;
            } else if (cardsminted[msg.sender].LIST5Mints > 0 && LIST5Limit > 0) {
                cardsminted[msg.sender].LIST5Mints--;
                // subtract mint from LIST5 eligibility whitelist
                LIST5Limit--;
                return true;
            } else if (cardsminted[msg.sender].contributorMints > 0 && contributorLimit > 0) {
                cardsminted[msg.sender].contributorMints--;
                // subtract mint from contributor eligibility whitelist
                contributorLimit--;
                return true;
            }            
            return false;
    }
    
    event proofOfTale(uint256 indexed tokenId);

    function SpinAWhiteTale() internal {
        uint256 currentSupply = totalSupply();
        require(currentSupply < supplyCap, "Max Exceeded");

            uint256 tokenId = currentSupply + 1;
            
            // Conditional Mint to the Spartan Reserve for the Sparta of Sonic GambleFi app
            if (currentSupply > 0 && currentSupply % 10 == 0) {
                _mint(matchBetDAO, tokenId);
                //Map it
                blacklisted[tokenId] = BlackList({
                    blacklist: false
                });
                cardsminted[matchBetDAO].cardsmint++;
                emit proofOfTale(tokenId);
                tokenId++;  // Increment for the next mint
            }

            // Regular Mint
            _mint(msg.sender, tokenId);
            //record mint
            cardsminted[msg.sender].cardsmint++;
            
            //Map it
            blacklisted[tokenId] = BlackList({
                blacklist: false
            });
            
            emit proofOfTale(tokenId);
    }

    function SpinATale() internal {
        uint256 currentSupply = totalSupply();
        require(currentSupply < supplyCap, "Max Exceeded");

            uint256 tokenId = currentSupply + 1;
            
            // Conditional Mint to the Spartan Reserve for the Sparta of Sonic GambleFi app
            if (currentSupply > 0 && currentSupply % 10 == 0) {
                _mint(matchBetDAO, tokenId);
                //Map it
                blacklisted[tokenId] = BlackList({
                    blacklist: false
                });
                cardsminted[matchBetDAO].cardsmint++;
                emit proofOfTale(tokenId);
                tokenId++;  // Increment for the next mint
            }

            // Regular Mint
            _mint(msg.sender, tokenId);
            //record mint
            cardsminted[msg.sender].cardsmint++;
            
            //Map it
            blacklisted[tokenId] = BlackList({
                blacklist: false
            });
            
            emit proofOfTale(tokenId);
    }

    function mint() public payable nonReentrant {
        require(!paused, "Paused Contract");
        uint256 supply = totalSupply();
        require( supply < supplyCap, "Max Exceeded.");
        require (startTime < block.timestamp, "Mint Not Live!");

        if (whitelistState()) { 
            //Mint a Tale
            SpinAWhiteTale(); 

        } else {
          require((startTime + wlDuration) < block.timestamp, "Public Phase Has Not Yet Begun");
          require(msg.value == fee, "Insufficient fee");
          // Transfer required LIST1 tokens to mint a LIST1
            transferTokens(tokenFee); 
          // Initiate permaburn from the contract
            burn(tokenFee, toll);

            //Mint a Tale
            SpinATale();
        }
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

    function setValues (uint256 _feeEther, uint256 _tokenFeeEther, uint256 _payId, uint256[] calldata _taxes, 
      uint256 _startTime, uint256 _wlDuration, uint256[] calldata _mintLimits) external onlyMatchBetDAO() {
        fee = _feeEther * 1 ether;
        tokenFee = _tokenFeeEther * 1 ether;
        payId = _payId;
        toll = _taxes[0];
        deadtax = _taxes[1];
        devtax = _taxes[2];
        startTime = block.timestamp + (_startTime * 1 days);
        wlDuration = _wlDuration * 1 minutes;
        LIST1Limit = _mintLimits[0];
        LIST2Limit = _mintLimits[1];
        LIST3Limit = _mintLimits[2];
        LIST4Limit = _mintLimits[3];
        LIST5Limit = _mintLimits[4];
        contributorLimit = _mintLimits[5];
    }
    
    function changeOwner(address newOwner) external onlyMatchBetDAO {
        // Update the owner to the new owner
        transferOwnership(newOwner);
    }

    function withdraw(uint256 _amount) external payable onlyMatchBetDAO nonReentrant {
        address payable _owner = payable(owner());
        _owner.transfer(_amount);
    }

    function withdrawERC20(uint256 _payId, uint256 _amount) external payable onlyMatchBetDAO nonReentrant {
        TokenInfo storage tokens = AllowedCrypto[_payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transfer(msg.sender, _amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }

    function updateBaseURI(string memory _newLink) external onlyMatchBetDAO() {
        baseURI = _newLink;
    }

    function setBaseURItype() external onlyMatchBetDAO() {
      if (!baseURItype) {
        baseURItype = true;
      } else {
        baseURItype = false;
      }
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
      require(_tokenId <= totalSupply(), "Not Found");
      string memory uriBase = baseURI;
      if (blacklisted[_tokenId].blacklist) { 
        return
          bytes(uriBase).length > 0
            ? string(abi.encodePacked(uriBase, "blacklisted", ".json"))
            : "";
      }

      if (baseURItype) {
        return
          bytes(uriBase).length > 0
            ? string(abi.encodePacked(uriBase, _tokenId.toString(), ".json"))
            : "";
        } 
        return
          bytes(uriBase).length > 0
            ? string(abi.encodePacked(uriBase, "alpha", ".json"))
            : "";
    }

    event Pause();
    function pause() public onlyMatchBetDAO {
        require(!paused, "Already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() public onlyMatchBetDAO {
        require(paused, "Not paused.");
        paused = false;
        emit Unpause();
    } 

    // Helpers
    function addToLIST1Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].LIST1owner = _amount[i];
        }
    }

    function addToLIST3Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].LIST3owner = _amount[i];
        }
    }

    function addToLIST2Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].LIST2owner = _amount[i];
        }
    }

    function addToLIST4Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].LIST4Community = _amount[i];
        }
    }

    function addToLIST5Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].LIST5Contributor = _amount[i];
        }
    }

    function addToEarlyWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].earlyContributor = _amount[i];
        }
    }

    function addToBlacklist(uint256[] calldata _nfts) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = true;
        }
    }

    function removeFromWhitelist(address[] calldata _address) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = false;
            whitelisted[_address[i]].LIST1owner = 0;
            whitelisted[_address[i]].LIST3owner = 0;
            whitelisted[_address[i]].LIST2owner = 0;
            whitelisted[_address[i]].LIST4Community = 0;
            whitelisted[_address[i]].LIST5Contributor = 0;
            whitelisted[_address[i]].earlyContributor = 0;
        }
    }

    function removeFromBlacklist(uint256[] calldata _nfts) external onlyMatchBetDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = false;
        }
    }

    function setBetDAO (address _matchBetDAO) external onlyMatchBetDAO {
        matchBetDAO = _matchBetDAO;
    }

    function setAddresses (address _address1, address _address2) external onlyMatchBetDAO {
        burnAddress = _address1;
        developmentAddress = _address2;
    }
    
    function setAuthor (string memory _reveal) external onlyMatchBetDAO {
        Author = _reveal;
    }
}
