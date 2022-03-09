// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Voting{

    address public commission;

    uint public countingTime;

    bytes32 [] public voters;

    int [] public votes;

    bool internal isVoterVoting;

    bool internal isVotesCounted;

    mapping(bytes32 => bool) votersExists;
    mapping(bytes32 => bool) hasVoted;

    mapping(int => int) partyVotes;

    // The constructor to save the address of the commission
    constructor(uint startCountingTime){
        commission = msg.sender;
        countingTime = startCountingTime;
    }

    // The modifier that allows only the election commission to access the functions
    modifier onlyElectionCommission() {
        require(msg.sender == commission,"Only the election commission can access this function.");
        _;
    }

    // The modifier that allows only one voter to vote at a time
    modifier allowOneVoterOnly() {
        require(!isVoterVoting,"Some one else is voting. Please wait and try again.");
        isVoterVoting = true;
        _;
        isVoterVoting = false;
    }

    // The modifier that allows to count vote only after the specific time
    modifier onlyAfterCountingTime() {
        require(countingTime <= block.timestamp, "Counting can not be started now.");
        isVotesCounted = true;
        _;
    }

    // The modifier that allows to view results only after the votes have been counted
    modifier onlyAfterCountingVotes() {
        require(isVotesCounted, "Results can be viewed only after the counting has been done.");
        _;
    }

    // The function to create a voter by the election commission
    function createVoter(string memory voterId) public onlyElectionCommission {
        bytes32 userId = sha256(abi.encodePacked(voterId));
        require(!votersExists[userId], "Account has already been created.");
        votersExists[userId] = true;
        voters.push(userId);
    }

    // The function to vote by the voters
    function vote(string memory voterId, int partyNumber) public allowOneVoterOnly {
        bytes32 userId = sha256(abi.encodePacked(voterId));
        require(votersExists[userId], "This voter is not atunticated by the election commission.");
        require(!hasVoted[userId], "This voter has already voted.");
        hasVoted[userId] = true;
        votes.push(partyNumber);
    }
    
    // The function to count the number of votes
    function countVotes() public onlyAfterCountingTime{
        uint indexVotes = 0;
        uint numberOfVotes = votes.length;
        while (numberOfVotes != 0) {
            int currentVote = votes[indexVotes];
            partyVotes[currentVote] = partyVotes[currentVote] + 1;
            indexVotes++;
            numberOfVotes--;
        }
    }

    // The function to send the votes
    function viewResultsOf(int partyNumber) public view onlyAfterCountingVotes returns(int){
        return partyVotes[partyNumber];
    }

}