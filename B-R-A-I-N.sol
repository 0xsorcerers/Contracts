// @title The B.R.A.I.N on Sonic Network
// Big-data reasoning and autonomous intelligence neural node 
// website: https://brainonsonic.xyz | telegram: https://t.me/Oxsorcerer | twitter: https://x.com/brainonsonic 

pragma solidity ^0.8.18;

contract BRAIN is ERC721Enumerable, Ownable, ReentrancyGuard {        
        constructor(string memory _name, string memory _symbol, address _brainDAO, address _brainAddress) 
            ERC721(_name, _symbol)
        {
            brainDAO = _brainDAO;
            brainAddress = _brainAddress;
        }  
    using SafeERC20 for IERC20;  
    using Strings for uint256;

    uint256 count = 0;
    uint256 conversations = 0;
    uint256 public fee = 0.00001 ether;
    uint256 public payId = 0;
    uint256 public brainFee = 1000 ether;
    uint256 public TotalBurns = 0;
    uint256 public deadtax = 0;
    uint256 public devtax = 0;
    uint256 public toll = 0;
    uint256 private limitCount = 1;
    address public brainDAO; 
    address public brainAddress;
    address payable public developmentAddress;
    address public burnAddress;
    string public baseURI;
    string public Author = "undoxxed";
    bool public baseURItype = false; 
    bool public paused = false; 

    modifier onlyBrainDAO() {
        require(msg.sender == brainDAO, "Not authorized.");
        _;
    }

    modifier onlyBurner() {
        require(msg.sender == brainAddress, "Not authorized.");
        _;
    }

    struct Brainer {
        string username;
        uint256 id;
        string bot;
        string build;
        string class;
        string topic;
        string tid;
        uint256 contributions;
        uint256 history;
    }

    struct TokenInfo {
        IERC20 paytoken;
    }

    struct WhiteList {
        bool whitelist;       
    }

    struct BlackList {
        bool blacklist;       
    }

    //Array
    TokenInfo[] public AllowedCrypto;

    //Maps
    mapping (uint256 => Brainer) public brainers;
    mapping (address => WhiteList) public whitelisted;
    mapping (uint256 => BlackList) public blacklisted;
    mapping (uint256 => string) private dialogue;

    event brainMint(string _name, uint256 indexed tokenId);

    function mint(string memory _name, string memory _robot, string memory _buildString) public payable nonReentrant {
        require(!paused, "Paused Contract");
        require(bytes(_name).length > 0, "No Name"); 
        if (!whitelisted[msg.sender].whitelist) {
          require(balanceOf(msg.sender) < limitCount, "Not Authorized");
          require(msg.value == fee, "Insufficient fee");
          // Transfer required brain tokens to mint a brain
          transferTokens(brainFee); 
          // Initiate permaburn from the contract
          burn(brainFee, toll);
        }
        
        uint256 tokenId = count + 1;

        // Create and map new brainer
        brainers[tokenId] = Brainer({
            username: _name,
            id: tokenId,
            bot: _robot,
            build: _buildString,
            class: '',
            topic: '',
            tid: '',
            contributions: 0,
            history: 0});

        // Mint a new brain
        _mint(msg.sender, tokenId);

        //Create Blacklist and map it
        blacklisted[tokenId] = BlackList({
            blacklist: false
        });
        
        emit brainMint(_name, tokenId);
        count++;
    }

    event updatedBrain(string indexed _name, uint256 indexed tokenId);

    function updateBrainer(uint256 _tokenId, string memory _newName, string memory _robot, string memory _buildString, 
      string memory _class, string memory _topicString, string memory _tidString, bytes32 providedHash) external nonReentrant {
       require(providedHash == secretHash, "Invalid hash provided");
       require(msg.sender == ownerOf(_tokenId), "Not Your Brain.");
       require(bytes(_newName).length > 0, "No Name");
       require(_tokenId >= 0 && _tokenId <= totalSupply(), "Not Found");
       require(!blacklisted[_tokenId].blacklist, "Blacklisted"); 
        // Update the data in brainer
        brainers[_tokenId].username = string(_newName);
        brainers[_tokenId].bot = string(_robot);
        brainers[_tokenId].build = string(_buildString);
        brainers[_tokenId].class = string(_class);
        brainers[_tokenId].topic = string(_topicString);
        brainers[_tokenId].tid = string(_tidString);
        brainers[_tokenId].history++;

        emit updatedBrain(_robot, _tokenId);
    }

    function fetchDialogue(uint256[] calldata _data, bytes32 providedHash) external nonReentrant returns (string[] memory) {
      require(providedHash == secretHash, "Invalid hash provided");
      // Initialize our array
        string[] memory results = new string[](_data.length);
        for (uint256 i = 0; i < _data.length; i++) {
            results[i] = dialogue[_data[i]];
        }
        return results;
    }

    function putDialogue(string memory _dialogue, bytes32 providedHash) external nonReentrant {
      require(providedHash == secretHash, "Invalid hash provided");
        dialogue[conversations] = _dialogue;
        conversations++;
    }

    function setContributions(uint8 _type, uint256 _tokenId, uint256 _amount) external onlyBrainDAO() {
        require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
        if (_type > 0) {
        brainers[_tokenId].contributions += _amount;
        } else {          
        brainers[_tokenId].contributions = _amount;
        }
    }
    
    // Private variable to store the hashed secret
    bytes32 private secretHash;

    /**
     * @dev Function to set the secret value, callable only by authorized party.
     * @param _secret The secret string to hash and store
     */
    function setSecret(string memory _secret) external onlyBrainDAO {
        secretHash = keccak256(abi.encodePacked(_secret));
    }

    function setBrainAddress (address _brainAddress) external onlyBrainDAO {
        require(msg.sender == brainDAO, "Not Authorized.");
        brainAddress = _brainAddress;
    }

    function setValues (uint256 _fee, uint256 _brainFee, uint256 _deadtax, uint256 _toll,
      uint256 _devtax, uint256 _payId, uint256 _limitCount) external onlyBrainDAO() {
        fee = _fee;
        deadtax = _deadtax;
        devtax = _devtax;
        payId = _payId;
        toll = _toll;
        brainFee = _brainFee;
        limitCount = _limitCount;
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
    
    function changeOwner(address newOwner) external onlyBrainDAO {
        // Update the owner to the new owner
        transferOwnership(newOwner);
    }

    function withdraw(uint256 _amount) external payable onlyBrainDAO nonReentrant {
        address payable _owner = payable(owner());
        _owner.transfer(_amount);
    }

    function withdrawERC20(uint256 _payId, uint256 _amount) external payable onlyBrainDAO nonReentrant {
        TokenInfo storage tokens = AllowedCrypto[_payId];
        IERC20 paytoken;
        paytoken = tokens.paytoken;
        paytoken.transfer(msg.sender, _amount);
    }

    function setAddresses(address _developmentAddress, address _burnAddress) public onlyBrainDAO {
        developmentAddress = payable (_developmentAddress);
        burnAddress = _burnAddress;
    }
    
    function addCurrency(IERC20 _paytoken) external onlyBrainDAO {
        AllowedCrypto.push(
            TokenInfo({
                paytoken: _paytoken
            })
        );
    }

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }

    function updateBaseURI(string memory _newLink) external onlyBrainDAO() {
        baseURI = _newLink;
    }

    function setBaseURItype() external onlyBrainDAO() {
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
    function pause() public onlyBrainDAO {
        require(!paused, "Already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() public onlyBrainDAO {
        require(paused, "Not paused.");
        paused = false;
        emit Unpause();
    } 

    // Getters
    function getBrainer(uint256 _tokenId) public view returns (Brainer[] memory) {
        Brainer[] memory brainBoard = new Brainer[](1);
        brainBoard[0] = brainers[_tokenId];
        return brainBoard;
    }

    function getBrains(address _player) public view returns (Brainer[] memory) {
        uint256 total = balanceOf(_player);
        Brainer[] memory result = new Brainer[](total);
        for (uint256 i = 0; i < total; i++) {
          uint256 tokenId = tokenOfOwnerByIndex(_player, i);
                result[i] = brainers[tokenId];
        }
        return result;
    } 

    function burnBrains(uint256 _amount, uint256 _toll, bytes32 providedHash) external {
      require(providedHash == secretHash, "Invalid hash provided");
      burn(_amount, _toll);
    }

    function addToWhitelist(address[] calldata _address) external onlyBrainDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = true;
        }
    }

    function addToBlacklist(uint256[] calldata _nfts) external onlyBrainDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = true;
        }
    }

    function removeFromWhitelist(address[] calldata _address) external onlyBrainDAO {
        for (uint256 i = 0; i < _address.length; i++) {
            whitelisted[_address[i]].whitelist = false;
        }
    }

    function removeFromBlacklist(uint256[] calldata _nfts) external onlyBrainDAO {
        for (uint256 i = 0; i < _nfts.length; i++) {
            blacklisted[_nfts[i]].blacklist = false;
        }
    }

    function setDAO (address _brainDAO) external onlyBrainDAO {
        brainDAO = _brainDAO;
    }
    

    function setAuthor (string memory _reveal) external onlyBrainDAO {
        Author = _reveal;
    }
}
