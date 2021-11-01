import "https://raw.githubusercontent.com/klaytn/klaytn-contracts/master/contracts/token/KIP7/KIP7Token.sol";
pragma experimental ABIEncoderV2;

contract KDT is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata {
    
    enum Phase { Init, Pending, Done }
    
    struct Sponsor {
        address artist;
        uint256 amount;
        Phase state;
        Message message;
    }
    
    struct Message {
        string question;
        string answer;
    }
    
    mapping(address => Sponsor) sponsors;
    
    modifier validPhase(Phase reqPhase) {
        require(sponsors[msg.sender].state == reqPhase);
        _;
    }
    
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) KIP7Metadata(name, symbol, decimals) public {
        _mint(msg.sender, initialSupply);
    }
    
    function registerSponser(address artist, string memory question, uint256 amount) public validPhase(Phase.Init) {
        sponsors[msg.sender] = Sponsor({
            artist: artist,
            amount: amount,
            state: Phase.Pending,
            message: Message({
                question: question,
                answer: ""
            })
        });
    }
    
    function answerArtist(address sponsor, string memory answer) public {
        require(sponsors[sponsor].state == Phase.Pending);
        require(sponsors[sponsor].artist == msg.sender);
        
        sponsors[sponsor].message.answer = answer;
        sponsors[sponsor].state = Phase.Done;
        
        // transferFrom(sponsor, msg.sender, 10000);
        sponsors[sponsor].amount = 0;
    }
    
    function resetSponser() public validPhase(Phase.Done) {
        sponsors[msg.sender].artist = address(0);
        sponsors[msg.sender].amount = 0;
        sponsors[msg.sender].state = Phase.Init;
        sponsors[msg.sender].message.question = "";
        sponsors[msg.sender].message.answer = "";
    }
    
    function getMessage() public view returns (string memory, string memory) {
        return (sponsors[msg.sender].message.question, sponsors[msg.sender].message.answer);
    }
}
