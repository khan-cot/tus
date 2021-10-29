pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
        return c;
    }
}

    
contract Farm is ReentrancyGuard,ERC721Holder {
    using SafeMath for uint256;
    using Strings for uint256;
    
    uint256 public constant UNIT_BALANCE = 100 * 10**18;
    
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Vault: TRANSFER_FAILED');
    }
    
    /* ========== STATE VARIABLES ========== */
    mapping(address => uint256) _fields;
    mapping(address => uint256) _seeds;
    mapping(uint256 => uint8) _fieldLevel;
    mapping(uint256 => uint8) _seedLevel;
    mapping(uint256 => address) _owners;
    
    uint256 private _baseid;
   
    address private _reward;
    address private _vault;
    address public owner;
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _baseURI() internal view returns (string memory) {
        return "";
    }
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    
     /* ========== EVENTS ========== */
    event Withdrawn(address indexed token,address user, uint256 amount0,uint256 amount1);
    event Deposit(address indexed token,address user, uint256 amount);
    /* ========== CONSTRUCTOR ========== */
    constructor(address reward) {
        owner = msg.sender;
        _reward = reward;
        _baseid = 100;
    }
    
    function _mint(address to,uint8 level) internal {
        uint256 fid = _baseid;
        _baseid += 1;
        uint sid = _baseid;
        _baseid += 1;
        
        _fields[to] = fid;
        _seeds[to] = sid;
      
        _fieldLevel[fid] = level;
        _seedLevel[sid] = level;
        
        _owners[fid] = to;
        _owners[sid] = to;
    }
    
    function deposit(address token,uint256 amount) external {
        require(token == _vault,"only vault token");
        require(amount > UNIT_BALANCE,"low amount");
        
        IERC20(_vault).transferFrom(msg.sender,address(this),amount);
        
        emit Deposit(token,msg.sender,amount);
    }
    function plant(uint256 seed) external {
        
    }
    
}

    
    
    
    
    