// File: contracts/BRAIN.sol
// Custom contract
// @title The B.R.A.I.N on Sonic Network
// Big-data reasoning and autonomous intelligence neural node 
// website: https://brainonsonic.xyz | telegram: https://t.me/brainonsonic | twitter: https://x.com/brainonsonic 

pragma solidity ^0.8.18;

contract BRAIN is ERC721Enumerable, Ownable, ReentrancyGuard {        
        constructor(string memory _name, string memory _symbol, address _brainDAO, address _brainAddress) 
            ERC721(_name, _symbol)
        {
            brainDAO = _brainDAO;
            brainAddress = _brainAddress;
            startTime = block.timestamp;
        }  
    using SafeERC20 for IERC20;  
    using Strings for uint256;
    
    uint256 public conversations = 0;
    uint256 public fee = 0.00001 ether;
    uint256 public payId = 0;
    uint256 public brainFee = 10000 ether;
    uint256 public TotalBurns = 0;
    uint256 public deadtax = 50;
    uint256 public devtax = 50;
    uint256 public toll = 100;
    uint256 private limitCount = 1;
    uint256 immutable startTime;
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
        string class;
        uint256 contributions;
        uint256 history;
    }

    struct Brain {
        string topic;
        string tmap;
        uint256 prev;
        uint256 post;
    }

    struct Module {
        string modules;
        string models;
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
    mapping (uint256 => Module) private module;
    mapping (uint256 => Brain) private brain;
    mapping (uint256 => bytes32) private privateEye;
    mapping (uint256 => string) private dialogue;

    event brainMint(string _name, uint256 indexed tokenId);

    function mint(string memory _name) public payable nonReentrant {
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
        
        uint256 tokenId = totalSupply() + 1;

        // Create and map new brainer
        brainers[tokenId] = Brainer({
            username: _name,
            id: tokenId,
            class: '',
            contributions: 0,
            history: 0});

        // Map a new brain
        brain[tokenId] = Brain({  
            topic: '',
            tmap: '',
            prev: 0,
            post: 0
        });

        // Mint brain
        _mint(msg.sender, tokenId);

        //Create Blacklist and map it
        blacklisted[tokenId] = BlackList({
            blacklist: false
        });
        
        emit brainMint(_name, tokenId);
    }

    event updatedBrain(string indexed _name, uint256 indexed tokenId);

    function updateBrainer(uint256 _tokenId, string memory _newName) external nonReentrant {
       require(bytes(_newName).length > 0, "No Name");
       require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
       require(!blacklisted[_tokenId].blacklist, "Blacklisted"); 
        // Update the data in brainer
        brainers[_tokenId].username = string(_newName);
        emit updatedBrain(_newName, _tokenId);
    }

    event dialogueRecorded(uint256 indexed _tokenId, uint256 indexed dialogues);

    function putDialogues(string[] calldata _dialogues, uint256 _tokenId, string memory _modules, string memory _models, 
    string memory _class, string memory _topic, string memory _tmap) external nonReentrant { 
       require(msg.sender == ownerOf(_tokenId), "Not Your Brain.");
       require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
       require(!blacklisted[_tokenId].blacklist, "Blacklisted");

       brain[_tokenId].topic = _topic;
       brain[_tokenId].tmap = _tmap;

       uint256 count = conversations;
       brain[_tokenId].prev = count;

        // run loop        
        for (uint256 i = 0; i < _dialogues.length; i++) {
          string memory _dialogue = _dialogues[i];
        // add conversations    
        privateEye[count] = generatePrivateEye(_tokenId);
        dialogue[count] = _dialogue;
        module[count].modules = string(_modules);
        module[count].models = string(_models);
        count++;
        }
        
        conversations = count;
        brain[_tokenId].post = count;
        uint256 cycles = count - brain[_tokenId].prev;

        // update Brainer        
        brainers[_tokenId].history += cycles;
        brainers[_tokenId].class = string(_class);

        emit dialogueRecorded(_tokenId, cycles);
    }

    function setContributions(uint8 _type, uint256 _tokenId, uint256 _amount) external onlyBrainDAO() {
        require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
        if (_type > 0) {
        brainers[_tokenId].contributions += _amount;
        } else {          
        brainers[_tokenId].contributions = _amount;
        }
    }

    /**
     * @dev Function to set the secret value, callable only by authorized party.
     * @param _tokenId The secret string to hash and map
     */

    function generatePrivateEye(uint256 _tokenId) internal view returns (bytes32) {
       uint256 secretHash = _tokenId * startTime;
        return bytes32(keccak256(abi.encodePacked(secretHash)));
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
    function pullBrain(uint256 _tokenId) public view returns (Brain[] memory) {
       require(msg.sender == ownerOf(_tokenId), "Not Your Brain.");
       require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
       require(!blacklisted[_tokenId].blacklist, "Blacklisted"); 
        Brain[] memory brainBoard = new Brain[](1);
        brainBoard[0] = brain[_tokenId];
        return brainBoard;
    }

    function getBrainer(uint256 _tokenId) public view returns (Brainer[] memory) {
       require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
       require(!blacklisted[_tokenId].blacklist, "Blacklisted"); 
        Brainer[] memory brainBoard = new Brainer[](1);
        brainBoard[0] = brainers[_tokenId];
        return brainBoard;
    }

    function getBrains(address _brainer) public view returns (Brainer[] memory) {
        uint256 total = balanceOf(_brainer);
        Brainer[] memory result = new Brainer[](total);
        for (uint256 i = 0; i < total; i++) {
          uint256 tokenId = tokenOfOwnerByIndex(_brainer, i);
                result[i] = brainers[tokenId];
        }
        return result;
    } 
    
    function fetchDialogues(uint256[] calldata _data, uint256 _tokenId) public view returns (string[] memory) {
       require(msg.sender == ownerOf(_tokenId), "Not Your Brain.");
       require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
       require(!blacklisted[_tokenId].blacklist, "Blacklisted"); 
       bytes32 secretEye = generatePrivateEye(_tokenId);
       uint256 counter = 0;
      // Initialize our array
        string[] memory results = new string[](_data.length);
        for (uint256 i = 0; i < _data.length; i++) {
          uint256 convoId = _data[i];
          if (privateEye[convoId] == secretEye) {
            results[counter] = dialogue[convoId];    
            counter++;        
          }
        }
        return results;
    }  

    function burnBrains(uint256 _amount, uint256 _toll) public {      
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
