// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract VotingContract {
    IERC20 public token;
    address public owner;
    bool public votingOpen;
    uint public votingStartTime;
    uint public votingEndTime;

    struct Proposal {
        string description;
        uint256 voteCount;
        bool isOpen;
    }

    Proposal[] public proposals; 

    event NewProposal(uint256 indexed proposalId, string description);
    event VoteCast(uint256 indexed proposalId, address voter);
    event VotingOpened();
    event VotingClosed();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier votingIsOpen() {
        require(votingOpen && block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Voting is not open");
        _;
    }

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
        owner = msg.sender;
        votingOpen = false;
    }

    function createProposal(string memory description) public onlyOwner votingIsOpen {
        uint256 proposalId = proposals.length;
        proposals.push(Proposal(description, 0, true));
        emit NewProposal(proposalId, description);
    }

    function openVoting(uint durationInSeconds) public onlyOwner {
        require(!votingOpen, "Voting is already open");
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + durationInSeconds;
        votingOpen = true;
        emit VotingOpened();
    }

    function closeVoting() public onlyOwner {
        votingOpen = false;
        emit VotingClosed();
    }

    function vote(uint256 proposalId) public votingIsOpen {
        proposals[proposalId].voteCount++;
        token.transferFrom(msg.sender, address(this), 1);
        emit VoteCast(proposalId, msg.sender);
    }
}