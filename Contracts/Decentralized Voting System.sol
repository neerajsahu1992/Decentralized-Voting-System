// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    // Struct to represent a proposal
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        uint256 deadline;
        bool executed;
        address proposer;
    }
    
    // Mapping to store proposals
    mapping(uint256 => Proposal) public proposals;
    
    // Mapping to track if an address has voted on a specific proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    // Mapping to store registered voters
    mapping(address => bool) public registeredVoters;
    
    // State variables
    uint256 public proposalCount;
    address public admin;
    uint256 public constant VOTING_DURATION = 7 days;
    
    // Events
    event ProposalCreated(uint256 indexed proposalId, string description, address indexed proposer);
    event VoteCast(uint256 indexed proposalId, address indexed voter);
    event VoterRegistered(address indexed voter);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(registeredVoters[msg.sender], "You must be a registered voter");
        _;
    }
    
    modifier proposalExists(uint256 _proposalId) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Proposal does not exist");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        registeredVoters[admin] = true; // Admin is automatically registered
    }
    
    /**
     * @dev Core Function 1: Create a new proposal
     * @param _description Description of the proposal
     */
    function createProposal(string memory _description) external onlyRegisteredVoter {
        require(bytes(_description).length > 0, "Proposal description cannot be empty");
        
        proposalCount++;
        
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            voteCount: 0,
            deadline: block.timestamp + VOTING_DURATION,
            executed: false,
            proposer: msg.sender
        });
        
        emit ProposalCreated(proposalCount, _description, msg.sender);
    }
    
    /**
     * @dev Core Function 2: Cast a vote on a proposal
     * @param _proposalId ID of the proposal to vote on
     */
    function vote(uint256 _proposalId) external onlyRegisteredVoter proposalExists(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        
        require(block.timestamp <= proposal.deadline, "Voting period has ended");
        require(!hasVoted[_proposalId][msg.sender], "You have already voted on this proposal");
        require(!proposal.executed, "Proposal has already been executed");
        
        hasVoted[_proposalId][msg.sender] = true;
        proposal.voteCount++;
        
        emit VoteCast(_proposalId, msg.sender);
    }
    
    /**
     * @dev Core Function 3: Register a new voter (Admin only)
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) external onlyAdmin {
        require(_voter != address(0), "Invalid voter address");
        require(!registeredVoters[_voter], "Voter is already registered");
        
        registeredVoters[_voter] = true;
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Get proposal details
     * @param _proposalId ID of the proposal
     * @return Proposal details
     */
    function getProposal(uint256 _proposalId) external view proposalExists(_proposalId) 
        returns (uint256, string memory, uint256, uint256, bool, address) {
        Proposal memory proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.voteCount,
            proposal.deadline,
            proposal.executed,
            proposal.proposer
        );
    }
    
    /**
     * @dev Check if voting is still active for a proposal
     * @param _proposalId ID of the proposal
     * @return bool indicating if voting is active
     */
    function isVotingActive(uint256 _proposalId) external view proposalExists(_proposalId) returns (bool) {
        return block.timestamp <= proposals[_proposalId].deadline && !proposals[_proposalId].executed;
    }
    
    /**
     * @dev Get total number of proposals
     * @return Total proposal count
     */
    function getTotalProposals() external view returns (uint256) {
        return proposalCount;
    }
}
