// @title Jesse And the Cybernauts Base MiniApp NFT Game Cards
// website: https://cybernauts.fun

pragma solidity ^0.8.18;

contract CYBERNAUTS is ERC721Enumerable, Ownable, ReentrancyGuard {        
        constructor(string memory _name, string memory _symbol, address _cybernautDAO) 
            ERC721(_name, _symbol)
        {
            cybernautDAO = _cybernautDAO;
        }  
    using SafeERC20 for IERC20;  
    using Strings for uint256;
    
    address public cybernautDAO; 
    address public cybernautAddress;
    address private developmentAddress;
    address public burnAddress;
    string public baseURI;
    uint256 public fee = 0 ether;
    uint256 public cyberFee = 2000 ether;
    uint256 public payId = 0;
    uint256 public immutable supplyCap = 5000;
    uint256 private startTime = block.timestamp + 1 days;
    uint256 private wlDuration = 60 minutes;
    uint256 public toll = 100;
    uint256 public deadtax = 10;
    uint256 public devtax = 40;
    uint256 public gametax = 50;
    uint256 public TotalBurns = 0;
    uint256 public TotalGameDeposits = 0;
    uint256 public air1Limit = 100;
    uint256 public air2Limit = 100;
    uint256 public air3Limit = 100;
    uint256 public air4Limit = 100;
    uint256 public air5Limit = 70;
    uint256 public air6Limit = 30;
    string public Author = "undoxxed";
    bool public baseURItype = false; 
    bool public paused = false; 

    modifier onlyCybernautDAO() {
        require(msg.sender == cybernautDAO, "Not authorized.");
        _;
    }

    struct TokenInfo {
        IERC20 paytoken;
    }

    struct WhiteList {
        bool whitelist;
        uint256 air3NFTowner;
        uint256 air2NFTowner;
        uint256 air1NFTowner;
        uint256 air5Community;
        uint256 air4Contributor;
        uint256 earlyContributor;
    }

    struct BlackList {
        bool blacklist;       
    }

    struct CybernautMinted {
        uint256 cybernautmint;
        uint256 air3NFTmints;
        uint256 air2NFTmints;
        uint256 air1NFTmints;
        uint256 air5Mints;
        uint256 air4Mints;
        uint256 air6Mints;
    }

    //Array
    TokenInfo[] public AllowedCrypto;

    //Maps
    mapping (address => WhiteList) public whitelisted;
    mapping (uint256 => BlackList) public blacklisted;
    mapping (address => CybernautMinted) public cybernautminted;
    
    function addCurrency(IERC20 _paytoken) external onlyCybernautDAO {
        AllowedCrypto.push(
            TokenInfo({
                paytoken: _paytoken
            })
        );
    }

    function whitelistState() internal returns (bool) {
        if (!whitelisted[msg.sender].whitelist) return false;     
        uint256 cybernautUnminted = totalMintable();   
        if (cybernautUnminted > 0 && limitCompliance()) {
            return true;
        } 
        return false;        
    }

    function totalMintable() internal view returns (uint256) {
        uint256 cybernautOwned = cybernautminted[msg.sender].cybernautmint;
        uint256 cybernautMintable = whitelisted[msg.sender].air3NFTowner + whitelisted[msg.sender].air2NFTowner + whitelisted[msg.sender].air1NFTowner 
            + whitelisted[msg.sender].air5Community + whitelisted[msg.sender].air4Contributor + whitelisted[msg.sender].earlyContributor;
        uint256 cybernautUnminted = cybernautMintable - cybernautOwned;
          require(cybernautOwned <= cybernautMintable, "failsafe");
        return cybernautUnminted;
    }

    function limitCompliance() internal returns (bool) {
        if (cybernautminted[msg.sender].cybernautmint < 1) {          
            // initialize snapshot record of cybernautMint
        cybernautminted[msg.sender].air3NFTmints = whitelisted[msg.sender].air3NFTowner;
        cybernautminted[msg.sender].air2NFTmints = whitelisted[msg.sender].air2NFTowner;
        cybernautminted[msg.sender].air1NFTmints = whitelisted[msg.sender].air1NFTowner;
        cybernautminted[msg.sender].air5Mints = whitelisted[msg.sender].air5Community;
        cybernautminted[msg.sender].air4Mints = whitelisted[msg.sender].air4Contributor;
        cybernautminted[msg.sender].air6Mints = whitelisted[msg.sender].earlyContributor;
        } 

            //Objectively subtract mint from associated whitelist limit
            if (cybernautminted[msg.sender].air3NFTmints > 0 && air3Limit > 0) {
                cybernautminted[msg.sender].air3NFTmints--;
                // subtract mint from air3 eligibilty whitelist
                air3Limit--;
                return true;
            } else if (cybernautminted[msg.sender].air2NFTmints > 0 && air2Limit > 0) {
                cybernautminted[msg.sender].air2NFTmints--;
                // subtract mint from air2 eligibility whitelist
                air2Limit--;
                return true;
            } else if (cybernautminted[msg.sender].air1NFTmints > 0 && air1Limit > 0) {
                cybernautminted[msg.sender].air1NFTmints--;
                //subtract mint from air1 eligibility whitelist
                air1Limit--;
                return true;
            } else if (cybernautminted[msg.sender].air5Mints > 0 && air5Limit > 0) {
                cybernautminted[msg.sender].air5Mints--;
                // subtract mint from air5 eligibility whitelist
                air5Limit--;
                return true;
            } else if (cybernautminted[msg.sender].air4Mints > 0 && air4Limit > 0) {
                cybernautminted[msg.sender].air4Mints--;
                // subtract mint from air4 eligibility whitelist
                air4Limit--;
                return true;
            } else if (cybernautminted[msg.sender].air6Mints > 0 && air6Limit > 0) {
                cybernautminted[msg.sender].air6Mints--;
                // subtract mint from air6 eligibility whitelist
                air6Limit--;
                return true;
            }            
            return false;
    }
    
    event proofOfCybernaut(uint256 indexed tokenId);

    function SpinAWhiteCybernaut() internal {
        uint256 currentSupply = totalSupply();
        require(currentSupply < supplyCap, "Max Exceeded");

            uint256 tokenId = currentSupply + 1;
            
            // Conditional Mint to the Spartan Reserve for the Sparta of Sonic GambleFi app
            if (currentSupply > 0 && currentSupply % 10 == 0) {
                _mint(cybernautDAO, tokenId);
                //Map it
                blacklisted[tokenId] = BlackList({
                    blacklist: false
                });
                cybernautminted[cybernautDAO].cybernautmint++;
                emit proofOfCybernaut(tokenId);
                tokenId++;  // Increment for the next mint
            }

            // Regular Mint
            _mint(msg.sender, tokenId);
            //record mint
            cybernautminted[msg.sender].cybernautmint++;
            
            //Map it
            blacklisted[tokenId] = BlackList({
                blacklist: false
            });
            
            emit proofOfCybernaut(tokenId);

    }

    function SpinACybernaut() internal {
        uint256 currentSupply = totalSupply();
        require(currentSupply < supplyCap, "Max Exceeded");

            uint256 tokenId = currentSupply + 1;
            
            // Conditional Mint to the Spartan Reserve for the Sparta of Sonic GambleFi app
            if (currentSupply > 0 && currentSupply % 10 == 0) {
                _mint(cybernautDAO, tokenId);
                //Map it
                blacklisted[tokenId] = BlackList({
                    blacklist: false
                });
                cybernautminted[cybernautDAO].cybernautmint++;
                emit proofOfCybernaut(tokenId);
                tokenId++;  // Increment for the next mint
            }

            // Regular Mint
            _mint(msg.sender, tokenId);
            //record mint
            cybernautminted[msg.sender].cybernautmint++;
            
            //Map it
            blacklisted[tokenId] = BlackList({
                blacklist: false
            });
            
            emit proofOfCybernaut(tokenId);
    }

    function mint() public payable nonReentrant {
        require(!paused, "Paused Contract");
        uint256 supply = totalSupply();
        require( supply < supplyCap, "Max Exceeded.");
        require (startTime < block.timestamp, "Mint Not Live!");

        if (whitelistState()) { 
            //Mint a Cybernaut
            SpinAWhiteCybernaut(); 

        } else {
          require((startTime + wlDuration) < block.timestamp, "Public Phase Has Not Yet Begun");
          require(msg.value == fee, "Insufficient fee");
          // Transfer required air3 tokens to mint a air3
            transferTokens(cyberFee); 
          // Initiate permaburn from the contract
            burn(cyberFee, toll);

            //Mint a Cybernaut
            SpinACybernaut();
        }
    }

    function burn(uint256 _burnAmount, uint256 _num) internal {
        uint256 taxed = (_burnAmount * _num)/100 ;

        uint256 dead = (taxed * deadtax)/100;
        uint256 dev =  (taxed * devtax)/100;
        uint256 game = (taxed * gametax)/100;

        TokenInfo storage tokens = AllowedCrypto[payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;               
        paytoken.transfer(burnAddress, dead);   
        paytoken.transfer(developmentAddress, dev); 
        paytoken.transfer(cybernautAddress, game); 
        TotalBurns += dead;
        TotalGameDeposits += game;       
    }
    
    function transferTokens(uint256 _cost) internal {
        TokenInfo storage tokens = AllowedCrypto[payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transferFrom(msg.sender,address(this), _cost);
    }

    function setValues (uint256 _feeWei, uint256 _cyberFeeEther, uint256 _payId, uint256[] calldata _taxes, 
    uint256 _startTime, uint256 _wlDuration, uint256[] calldata _mintLimits) external onlyCybernautDAO() {
        fee = _feeWei;
        cyberFee = _cyberFeeEther * 1 ether;
        payId = _payId;
        toll = _taxes[0];
        deadtax = _taxes[1];
        devtax = _taxes[2];
        gametax = _taxes[3];
        startTime = block.timestamp + (_startTime * 1 days);
        wlDuration = _wlDuration * 1 minutes;
        air3Limit = _mintLimits[0];
        air1Limit = _mintLimits[1];
        air2Limit = _mintLimits[2];
        air5Limit = _mintLimits[3];
        air4Limit = _mintLimits[4];
        air6Limit = _mintLimits[5];
    }
    
    function changeOwner(address newOwner) external onlyCybernautDAO {
        // Update the owner to the new owner
        transferOwnership(newOwner);
    }

    function withdraw(uint256 _amount) external payable onlyCybernautDAO nonReentrant {
        address payable _owner = payable(owner());
        _owner.transfer(_amount);
    }

    function withdrawERC20(uint256 _payId, uint256 _amount) external payable onlyCybernautDAO nonReentrant {
        TokenInfo storage tokens = AllowedCrypto[_payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transfer(msg.sender, _amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }

    function updateBaseURI(string memory _newLink) external onlyCybernautDAO() {
        baseURI = _newLink;
    }

    function setBaseURItype() external onlyCybernautDAO() {
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
    function pause() public onlyCybernautDAO {
        require(!paused, "Already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() public onlyCybernautDAO {
        require(paused, "Not paused.");
        paused = false;
        emit Unpause();
    } 

    // Helpers
    function addToAir3Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].air3NFTowner = _amount[i];
        }
    }

    function addToAir2Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].air2NFTowner = _amount[i];
        }
    }

    function addToAir1Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].air1NFTowner = _amount[i];
        }
    }

    function addToAir5Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].air5Community = _amount[i];
        }
    }

    function addToAir4Whitelist(address[] calldata _address, uint256[] calldata _amount) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].air4Contributor = _amount[i];
        }
    }

    function addToEarlyWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].earlyContributor = _amount[i];
        }
    }

    function addToBlacklist(uint256[] calldata _nfts) external onlyCybernautDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = true;
        }
    }

    function removeFromWhitelist(address[] calldata _address) external onlyCybernautDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = false;
            whitelisted[_address[i]].air3NFTowner = 0;
            whitelisted[_address[i]].air2NFTowner = 0;
            whitelisted[_address[i]].air1NFTowner = 0;
            whitelisted[_address[i]].air5Community = 0;
            whitelisted[_address[i]].air4Contributor = 0;
            whitelisted[_address[i]].earlyContributor = 0;
        }
    }

    function removeFromBlacklist(uint256[] calldata _nfts) external onlyCybernautDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = false;
        }
    }

    function setDAO (address _cybernautDAO) external onlyCybernautDAO {
        cybernautDAO = _cybernautDAO;
    }

    function setAddresses (address _address1, address _address2, address _address3) external onlyCybernautDAO {
        burnAddress = _address1;
        developmentAddress = _address2;
        cybernautAddress = _address3;
    }
    
    function setAuthor (string memory _reveal) external onlyCybernautDAO {
        Author = _reveal;
    }
}
