// File: contracts/TalesOfSparta.sol
// Custom contract
// @title Tales of Sparta 
// Original Storyboard Comic book Tales of Sparta on Sonic 
// website: https://sparta.my | telegram: https://t.me/spartaonsonic | twitter: https://x.com/spartaonsonic

pragma solidity ^0.8.18;

contract Tales_of_Sparta is ERC721Enumerable, Ownable, ReentrancyGuard {        
        constructor(string memory _name, string memory _symbol, address _spartanDAO) 
            ERC721(_name, _symbol)
        {
            spartanDAO = _spartanDAO;
        }  
    using SafeERC20 for IERC20;  
    using Strings for uint256;
    
    address public spartanDAO; 
    address private developmentAddress;
    address public burnAddress;
    string public baseURI;
    uint256 public fee = 100 ether;
    uint256 public sosFee = 0 ether;
    uint256 public payId = 0;
    uint256 public immutable supplyCap = 3333;
    uint256 private startTime = block.timestamp + 1 weeks;
    uint256 private wlDuration = 60 minutes;
    uint256 public toll = 100;
    uint256 public deadtax = 0;
    uint256 public devtax = 0;
    uint256 public TotalBurns = 0;
    uint256 public derpLimit = 100;
    uint256 public lazybearLimit = 100;
    uint256 public brainLimit = 100;
    uint256 public sosLimit = 100;
    uint256 public pythLimit = 70;
    uint256 public contributorLimit = 30;
    string public Author = "undoxxed";
    bool public baseURItype = false; 
    bool public paused = false; 

    modifier onlySpartanDAO() {
        require(msg.sender == spartanDAO, "Not authorized.");
        _;
    }

    struct TokenInfo {
        IERC20 paytoken;
    }

    struct WhiteList {
        bool whitelist;
        uint256 brainNFTowner;
        uint256 lazybearNFTowner;
        uint256 derpNFTowner;
        uint256 pythCommunity;
        uint256 sosContributor;
        uint256 earlyContributor;
    }

    struct BlackList {
        bool blacklist;       
    }

    struct TalesMinted {
        uint256 talesmint;
        uint256 brainNFTmints;
        uint256 lazybearNFTmints;
        uint256 derpNFTmints;
        uint256 pythMints;
        uint256 sosMints;
        uint256 contributorMints;
    }

    //Array
    TokenInfo[] public AllowedCrypto;

    //Maps
    mapping (address => WhiteList) public whitelisted;
    mapping (uint256 => BlackList) public blacklisted;
    mapping (address => TalesMinted) public talesminted;
    
    function addCurrency(IERC20 _paytoken) external onlySpartanDAO {
        AllowedCrypto.push(
            TokenInfo({
                paytoken: _paytoken
            })
        );
    }

    function whitelistState() internal view returns (bool) {        
        uint256 talesUnminted = totalMintable();   
        if (talesUnminted > 0) {
            return true;
        } 
        return false;        
    }

    function totalMintable() internal view returns (uint256) {
        uint256 talesOwned = talesminted[msg.sender].talesmint;
        uint256 talesMintable = whitelisted[msg.sender].brainNFTowner + whitelisted[msg.sender].lazybearNFTowner + whitelisted[msg.sender].derpNFTowner 
            + whitelisted[msg.sender].pythCommunity + whitelisted[msg.sender].sosContributor + whitelisted[msg.sender].earlyContributor;
        uint256 talesUnminted = talesMintable - talesOwned;
          require(talesOwned <= talesMintable, "failsafe");
        return talesUnminted;
    }

    function limitCompliance() internal returns (bool) {
        if (talesminted[msg.sender].talesmint < 1) {          
            // initialize snapshot record of talesMint
        talesminted[msg.sender].brainNFTmints = whitelisted[msg.sender].brainNFTowner;
        talesminted[msg.sender].lazybearNFTmints = whitelisted[msg.sender].lazybearNFTowner;
        talesminted[msg.sender].derpNFTmints = whitelisted[msg.sender].derpNFTowner;
        talesminted[msg.sender].pythMints = whitelisted[msg.sender].pythCommunity;
        talesminted[msg.sender].sosMints = whitelisted[msg.sender].sosContributor;
        talesminted[msg.sender].contributorMints = whitelisted[msg.sender].earlyContributor;
        } 

            //Objectively subtract mint from associated whitelist limit
            if (talesminted[msg.sender].brainNFTmints > 0) {
                // require eligiblity whitelist
                require(brainLimit > 0, "BRAIN Whitelist Exhausted");
                talesminted[msg.sender].brainNFTmints--;
                // subtract mint from brain eligibilty whitelist
                brainLimit--;
                return true;
            } else if (talesminted[msg.sender].lazybearNFTmints > 0) {
                // require eligibility whitelist
                require(lazybearLimit > 0, "LBEAR Whitelist Exhausted");
                talesminted[msg.sender].lazybearNFTmints--;
                // subtract mint from lazybear eligibility whitelist
                lazybearLimit--;
                return true;
            } else if (talesminted[msg.sender].derpNFTmints > 0) {
                // subtract eligibility whitelist
                require(derpLimit > 0, "DERP Whitelist Exhausted");
                talesminted[msg.sender].derpNFTmints--;
                //subtract mint from derp eligibility whitelist
                derpLimit--;
                return true;
            } else if (talesminted[msg.sender].pythMints > 0) {
                // subtract eligibility whitelist
                require(pythLimit > 0, "PYTH Whitelist Exhausted");
                talesminted[msg.sender].pythMints--;
                // subtract mint from pyth eligibility whitelist
                pythLimit--;
                return true;
            } else if (talesminted[msg.sender].sosMints > 0) {
                //subtract eligibilty whitelist
                require(sosLimit > 0, "SOS Whitelist Exhausted");
                talesminted[msg.sender].sosMints--;
                // subtract mint from sos eligibility whitelist
                sosLimit--;
                return true;
            } else if (talesminted[msg.sender].contributorMints > 0) {
                // subtract eligibility whitelist
                require(contributorLimit > 0, "Contributor Whitelist Exhausted");
                talesminted[msg.sender].contributorMints--;
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
                _mint(spartanDAO, tokenId);
                //Map it
                blacklisted[tokenId] = BlackList({
                    blacklist: false
                });
                talesminted[spartanDAO].talesmint++;
                emit proofOfTale(tokenId);
                tokenId++;  // Increment for the next mint
            }

            //Require Whitelist Limit Compliance
            require(limitCompliance(), "Failed Limit Compliance");

            // Regular Mint
            _mint(msg.sender, tokenId);
            //record mint
            talesminted[msg.sender].talesmint++;
            
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
                _mint(spartanDAO, tokenId);
                //Map it
                blacklisted[tokenId] = BlackList({
                    blacklist: false
                });
                talesminted[spartanDAO].talesmint++;
                emit proofOfTale(tokenId);
                tokenId++;  // Increment for the next mint
            }

            // Regular Mint
            _mint(msg.sender, tokenId);
            //record mint
            talesminted[msg.sender].talesmint++;
            
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
          // Transfer required brain tokens to mint a brain
            transferTokens(sosFee); 
          // Initiate permaburn from the contract
            burn(sosFee, toll);

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

    function setValues (uint256 _feeEther, uint256 _sosFeeEther, uint256 _payId, uint256[] calldata _taxes, 
    uint256 _startTime, uint256 _wlDuration, uint256[] calldata _mintLimits) external onlySpartanDAO() {
        fee = _feeEther * 1 ether;
        sosFee = _sosFeeEther * 1 ether;
        payId = _payId;
        toll = _taxes[0];
        deadtax = _taxes[1];
        devtax = _taxes[2];
        startTime = block.timestamp + (_startTime * 1 days);
        wlDuration = _wlDuration * 1 minutes;
        brainLimit = _mintLimits[0];
        derpLimit = _mintLimits[1];
        lazybearLimit = _mintLimits[2];
        pythLimit = _mintLimits[3];
        sosLimit = _mintLimits[4];
        contributorLimit = _mintLimits[5];
    }
    
    function changeOwner(address newOwner) external onlySpartanDAO {
        // Update the owner to the new owner
        transferOwnership(newOwner);
    }

    function withdraw(uint256 _amount) external payable onlySpartanDAO nonReentrant {
        address payable _owner = payable(owner());
        _owner.transfer(_amount);
    }

    function withdrawERC20(uint256 _payId, uint256 _amount) external payable onlySpartanDAO nonReentrant {
        TokenInfo storage tokens = AllowedCrypto[_payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transfer(msg.sender, _amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }

    function updateBaseURI(string memory _newLink) external onlySpartanDAO() {
        baseURI = _newLink;
    }

    function setBaseURItype() external onlySpartanDAO() {
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

    // Helpers
    function addToBrainWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].brainNFTowner = _amount[i];
        }
    }

    function addToLazyBearWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].lazybearNFTowner = _amount[i];
        }
    }

    function addToDerpWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].derpNFTowner = _amount[i];
        }
    }

    function addToPythWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].pythCommunity = _amount[i];
        }
    }

    function addToSosWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].sosContributor = _amount[i];
        }
    }

    function addToEarlyWhitelist(address[] calldata _address, uint256[] calldata _amount) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
            whitelisted[_address[i]].earlyContributor = _amount[i];
        }
    }

    function addToBlacklist(uint256[] calldata _nfts) external onlySpartanDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = true;
        }
    }

    function removeFromWhitelist(address[] calldata _address) external onlySpartanDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = false;
            whitelisted[_address[i]].brainNFTowner = 0;
            whitelisted[_address[i]].lazybearNFTowner = 0;
            whitelisted[_address[i]].derpNFTowner = 0;
            whitelisted[_address[i]].pythCommunity = 0;
            whitelisted[_address[i]].sosContributor = 0;
            whitelisted[_address[i]].earlyContributor = 0;
        }
    }

    function removeFromBlacklist(uint256[] calldata _nfts) external onlySpartanDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = false;
        }
    }

    function setDAO (address _spartanDAO) external onlySpartanDAO {
        spartanDAO = _spartanDAO;
    }

    function setAddresses (address _address1, address _address2) external onlySpartanDAO {
        burnAddress = _address1;
        developmentAddress = _address2;
    }
    
    function setAuthor (string memory _reveal) external onlySpartanDAO {
        Author = _reveal;
    }
}
