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
    string public baseURI;
    uint256 public fee = 25 ether;
    uint256 public payId = 0;
    uint256 public multiplier1 = 5;
    uint256 public multiplier2 = 1;
    uint256 public multiplier3 = 1;
    uint256 public supplyCap = 3333;
    string public Author = "undoxxed";
    bool public baseURItype = false; 
    bool public paused = false; 
    uint256 private startTime;
    uint256 private wlDuration = 60 minutes;

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
    }

    struct BlackList {
        bool blacklist;       
    }

    struct TalesMinted {
        uint256 talesmint;
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

    function totalMintable() internal view returns (uint256) {
        uint256 talesOwned = talesminted[msg.sender].talesmint;
        uint256 talesMintable = (whitelisted[msg.sender].brainNFTowner * multiplier1) + (whitelisted[msg.sender].lazybearNFTowner * multiplier2) + ((whitelisted[msg.sender].derpNFTowner * multiplier3));
        uint256 talesUnminted = talesMintable - talesOwned;
          require(talesOwned <= talesMintable, "failsafe");
        return talesUnminted;
    }
    
    event proofOfTale(uint256 indexed tokenId);

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
        talesminted[msg.sender].talesmint++;
        
        //Map it
        blacklisted[tokenId] = BlackList({
            blacklist: false
        });
        
        emit proofOfTale(tokenId);
    }

    function mint() public payable nonReentrant {
        require(!paused, "Paused Contract");
        if (whitelisted[msg.sender].whitelist) { 
            uint256 talesUnminted = totalMintable();   
            require(talesUnminted > 0, "Insufficient fee");
            SpinATale();
        } else {
          require((startTime + wlDuration) < block.timestamp, "Public Phase Has Not Yet Begun");
          require(msg.value == fee, "Insufficient fee");
            SpinATale();
        }
    }

    function setValues (uint256 _fee, uint256 _payId, uint256 _startTime, uint256 _wlDuration, uint256[] calldata _multipliers) external onlySpartanDAO() {
        fee = _fee;
        payId = _payId;
        startTime = _startTime;
        wlDuration = _wlDuration * 1 minutes;
        multiplier1 = _multipliers[0];
        multiplier2 = _multipliers[1];
        multiplier3 = _multipliers[2];
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
    

    function setAuthor (string memory _reveal) external onlySpartanDAO {
        Author = _reveal;
    }
}
