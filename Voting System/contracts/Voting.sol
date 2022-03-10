// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Voting{

    address public commission;

    uint public startTime;
    uint public endTime;

    bytes32 [] public voters;
    mapping(bytes32 => bool) votersExists;

    bool internal isVoterVoting;
    
    int [] public votes;
    mapping(bytes32 => bool) hasVoted;

    mapping(int => int) partyVotes;
    
    bool internal isVotesCounted;

    // The constructor to save the address of the election commission, start time and end tine.
    constructor(uint _startTime, uint _endTime){
        commission = msg.sender;
        startTime = _startTime;
        endTime = _endTime;
    }

    // The modifier that allows only the election commission to access the functions
    modifier onlyElectionCommission() {
        require(msg.sender == commission,"Only the election commission can access this function.");
        _;
    }

    // The modifier that allows only one voter to vote at a time
    modifier allowVoting() {
        require(startTime <= block.timestamp, "You can not vote now. The voting has not started yet.");
        require(endTime >= block.timestamp, "You can not vote now. The voting has been compleated.");
        require(!isVoterVoting,"Some one else is voting. Please wait and try again.");
        isVoterVoting = true;
        _;
        isVoterVoting = false;
    }

    // The modifier that allows to count vote only after the specific time
    modifier onlyAfterCountingTime() {
        require(endTime <= block.timestamp, "Counting can not be started now.");
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
    function vote(string memory voterId, int partyNumber) public allowVoting {
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

    // The function to view the resluts of a particular party
    function viewResultsOf(int partyNumber) public view onlyAfterCountingVotes returns(int){
        return partyVotes[partyNumber];
    }

}
