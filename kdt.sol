import "https://raw.githubusercontent.com/klaytn/klaytn-contracts/master/contracts/token/KIP7/KIP7Token.sol";
pragma experimental ABIEncoderV2;

contract KDT is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata {
    
    uint256 public msgIdx;
    
    struct Sponsor {
        address artist;
    }
    
    struct Message {
        string question;
        string answer;
        uint256 amount;
    }
    
    mapping(address => Sponsor) sponsors;
    mapping(uint256 => Message) messages;
    
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) KIP7Metadata(name, symbol, decimals) payable public {
        _mint(msg.sender, initialSupply);
    }
    
    function registerSponser(address artist, string memory question, uint256 amount) public {
        sponsors[msg.sender] = Sponsor({
            artist: artist
        });
        
        _transfer(msg.sender, address(this), amount * 1000000000000000000);
        messages[msgIdx].question = question;
        messages[msgIdx++].amount = amount;
    }
    
    function answerArtist(address sponsor, string memory answer, uint256 idx) public {
        require(sponsors[sponsor].artist == msg.sender);
        require(bytes(messages[idx].answer).length == 0);
        messages[idx].answer = answer;
        
        _transfer(address(this), msg.sender, messages[idx].amount * 1000000000000000000);
    }
    
    function resetSponser() public {
        sponsors[msg.sender].artist = address(0);
    }
    
    function getMessage(uint256 idx) public view returns (string memory, string memory) {
        return (messages[idx].question, messages[idx].answer);
    }
}
