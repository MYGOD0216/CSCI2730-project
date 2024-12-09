//Blackchain voting system code
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Election {
    struct Candidate {
        address addr;
        uint votes;
    }

    struct Voter {
        address addr;
        bool eligible;
        bool voted;
        bool delegated;
        uint candidateId;
        
        address[] whitelistedBy;
        uint whitelistCount;
        string feedback;
    }

    uint numCandidates = 0;
    uint numVoters = 0;
    uint VoteNo = 0;
    address RecentVoters;

    mapping(address => uint) candidateId;   // index = Id - 1
    mapping(address => uint) voterId;       // index = Id - 1
    mapping(address => uint) delegateId;
    uint winnerId;

    bool finished;

    Candidate[] candidates;
    Voter[] voters;

    mapping(address => bool) callEndElection;
    mapping(address => bool) callRestartElection;
    mapping(bytes32 => bool) anonymousvotes;
    uint endElectionCount = 0;
    uint restartElectionCount = 0;

    constructor(address[] memory _candidates) {
        for(uint i = 0; i < _candidates.length; i ++) {
            candidates.push(Candidate(_candidates[i], 0));
            numCandidates += 1;
            candidateId[_candidates[i]] = numCandidates;
        }
        finished = false;
        winnerId = 0;
    }

    function whitelistVoter(address _voter) external {
        require(!finished, "Election has already finished");
        require(candidateId[msg.sender] > 0, "Only candidate can whitelist the voter");
        if(voterId[_voter] == 0) {
            // add voter into the voters list
            voters.push(Voter(_voter, false, false,false, 0, new address[](numCandidates), 0, "/"));
            numVoters += 1;
            voterId[_voter] = numVoters;
        }
        Voter storage voter = voters[voterId[_voter] - 1];
        require(!voter.eligible, "Voter is already eligible to vote");
        for(uint i = 0; i < voter.whitelistCount; i ++) {
            require(msg.sender != voter.whitelistedBy[i], "Voter has already been whitelisted by you");
        }
        voter.whitelistedBy[voter.whitelistCount] = msg.sender;
        voter.whitelistCount += 1;
        if (voter.whitelistCount == numCandidates) {
            voter.eligible = true;
        }
    }

    function voteCandidate(address _candidate) external {
        require(!finished, "Election has already finished");
        require(candidateId[_candidate] > 0, "Candidate do not exist");
        require(candidateId[msg.sender] == 0, "Only voters can cast vote");
        require(voterId[msg.sender] > 0, "Voter is not added in the election");
        Voter storage voter = voters[voterId[msg.sender] - 1];
        require(voter.eligible, "Voter is not yet eligible to cast vote");
        require(!voter.voted, "Voter has already cast its vote");
        voter.candidateId = candidateId[_candidate];
        VoteNo += 1;
        RecentVoters = msg.sender;
        voter.voted = true;
        Candidate storage candidate = candidates[candidateId[_candidate] - 1];
        candidate.votes += 1;
    }

    function VoteCandidateWFB(address _candidate, string calldata _feedback) external{
        require(!finished, "Election has already finished");
        require(candidateId[_candidate] > 0, "Candidate do not exist");
        require(candidateId[msg.sender] == 0, "Only voters can cast vote");
        require(voterId[msg.sender] > 0, "Voter is not added in the election");
        Voter storage voter = voters[voterId[msg.sender] - 1];
        require(voter.eligible, "Voter is not yet eligible to cast vote");
        require(!voter.voted, "Voter has already cast its vote");
        voter.candidateId = candidateId[_candidate];
        VoteNo += 1;
        RecentVoters = msg.sender;
        voter.voted = true;
        voter.feedback = _feedback;
        Candidate storage candidate = candidates[candidateId[_candidate] - 1];
        candidate.votes += 1;

    }

    function anonymousVote(address _candidate) external {
        require(!finished, "Election has already finished");
        require(candidateId[_candidate] > 0, "Candidate does not exist");
        require(voterId[msg.sender] > 0, "Voter is not added to the election");
        Voter storage voter = voters[voterId[msg.sender] - 1];
        require(voter.eligible, "Voter is not eligible to cast a vote");
        bytes32 voteHash = keccak256(abi.encodePacked(msg.sender, _candidate));
        require(!anonymousvotes[voteHash], "Votes has already been cast by this voter");
        anonymousvotes[voteHash] = true;
        voter.voted = true;
        VoteNo += 1;
        Candidate storage candidate = candidates[candidateId[_candidate] - 1];
        candidate.votes += 1;
    }

    function electionCandidates() public view returns (address[] memory _addresses) {
        _addresses = new address[](candidates.length);
        for(uint i = 0; i < candidates.length; i ++) {
            _addresses[i] = candidates[i].addr;
        }
    }

    function getCandidate(uint _candidateId) public view returns (address) {
        require(_candidateId > 0, "Candidate Id must be > 0");
        require(_candidateId <= candidates.length, "Candidate Id do not exist");
        return candidates[_candidateId - 1].addr;
    }

    function endElection() external {
        // the election will end and the winner will be annouced. Only called when all candiates call this function
        require(!finished, "Election has already finished");
        require(candidateId[msg.sender] > 0, "Only candidate can call this function");
        require(callEndElection[msg.sender] == false, "You have already called this function. Wait for other candidates to call end to election");
        callEndElection[msg.sender] = true;
        endElectionCount += 1;
        if (endElectionCount == numCandidates) {
            // set the winner, mark election as finished and reset the varible for next time use
            uint maxVotes = 0;
            for(uint i = 0; i < numCandidates; i ++) {
                if (candidates[i].votes > maxVotes) {
                    maxVotes = candidates[i].votes;
                    winnerId = i + 1;
                }
            }
            for(uint i = 0; i < candidates.length; i ++) {
            callEndElection[candidates[i].addr] = false;
            } 
            endElectionCount = 0;
            finished = true;
        }
    }

    function restartElection() external {
        //restart the election 
        require(finished, "Election has not finished yet");
        require(candidateId[msg.sender] > 0, "Only candidate can call this function");
        require(callRestartElection[msg.sender] == false, "You have already called this function. Wait for other candidates to call restart to election");
        callRestartElection[msg.sender] = true;
        restartElectionCount += 1;
        if (restartElectionCount == numCandidates) {
            //reset the varible for next time use
            for(uint i = 0; i < candidates.length; i ++) {
            callRestartElection[candidates[i].addr] = false;
            } 
            VoteNo = 0;
            restartElectionCount = 0;
            finished = false;
        }
    }

    function getWinningCandidate() public view returns (address) {
        require(finished, "The election is still running");
        uint votesrequired = numVoters / 2;
        //only candidate can more then 50% of votes can win the election
        require(candidates[winnerId - 1].votes > votesrequired, "No candidate win the election"); 
        return candidates[winnerId - 1].addr;
    }

    function realTimeVote() public view returns (uint[] memory _vote) {
        //show the current vote distribution 
        _vote = new uint[](candidates.length);
        for(uint i = 0; i < candidates.length; i ++) {
            _vote[i] = candidates[i].votes;
        }
     }

    function voteChange(address _candidate) external {
        //allow the voters to change their decision before the end of election
        require(!finished, "Election has already finished");
        require(candidateId[_candidate] > 0, "Candidate do not exist");
        require(candidateId[msg.sender] == 0, "Only voters can cast vote");
        require(voterId[msg.sender] > 0, "Voter is not added in the election");
        Voter storage voter = voters[voterId[msg.sender] - 1];
        require(voter.eligible, "Voter is not yet eligible to cast vote");
        require(voter.voted, "Voter has not cast its vote yet");
        require(voter.candidateId != candidateId[_candidate], "Voter vote for the same candidate");
        candidates[voter.candidateId - 1].votes -= 1;
        voter.candidateId = candidateId[_candidate];
        candidates[candidateId[_candidate] - 1].votes += 1;
    } 

    function voteRevoke() external {
        //allow the voters to revoke their vote before the end of election
        require(!finished, "Election has already finished");
        require(candidateId[msg.sender] == 0, "Only voters can cast vote");
        require(voterId[msg.sender] > 0, "Voter is not added in the election");
        Voter storage voter = voters[voterId[msg.sender] - 1];
        require(voter.eligible, "Voter is not yet eligible to cast vote");
        require(voter.voted, "Voter has not cast its vote yet");
        candidates[voter.candidateId - 1].votes -= 1;
        VoteNo -= 1;
        voter.voted = false;
        voter.candidateId = 0;
    }

    function votedVoters() public view returns (address[] memory _addresses) {
        _addresses = new address[](voters.length);
        uint j = 0;
        for(uint i = 0; i < voters.length; i ++) {
            if (voters[i].voted) {
                _addresses[j] = voters[i].addr;
                j += 1;
            }  
        }
    }

    function eligibleVoters() public view returns (address[] memory _addresses) {
        _addresses = new address[](voters.length);
        uint j = 0;
        for(uint i = 0; i < voters.length; i ++) {
            if (voters[i].eligible) {
                _addresses[j] = voters[i].addr;
                j += 1;
            }  
        }
    }

    function voterDelegate(address _nonvoter) external {
        require(!finished, "Election has already finished");
        require(candidateId[msg.sender] == 0, "Only voters can cast vote");
        require(voterId[msg.sender] > 0, "Voter is not added in the election");
        require(voterId[_nonvoter] == 0, "Voter cannot be delegated by other voter");
        require(candidateId[_nonvoter] == 0, "Candidate cannot vote");
        Voter storage voter = voters[voterId[msg.sender] - 1];
        require(voter.eligible, "Voter is not yet eligible to cast vote");
        require(!voter.voted, "Voter has already cast its vote yet");
        voter.delegated = true;
        delegateId[_nonvoter] = voterId[msg.sender];
    }

    function voteAsDelegate(address _candidate) external {
        require(!finished, "Election has already finished");
        require(candidateId[_candidate] > 0, "Candidate do not exist");
        require(candidateId[msg.sender] == 0, "Only voters can cast vote");
        require(delegateId[msg.sender] > 0, "No right to vote in the election");
        Voter storage voter = voters[delegateId[msg.sender] - 1];
        require(voter.eligible, "Voter is not yet eligible to cast vote");
        require(!voter.voted, "Voter has already cast its vote yet");
        require(voter.delegated, "Voter does not assign their vote");
        voter.candidateId = candidateId[_candidate];
        voter.voted = true;
        VoteNo += 1;
        Candidate storage candidate = candidates[candidateId[_candidate] - 1];
        candidate.votes += 1;
    }

    function getFeedBack(address _voter) public view returns(string memory){
        require(voterId[_voter] > 0, "Voter does not exist");
        Voter storage voter = voters[voterId[_voter] - 1];
        require(voter.voted, "Voter has not cast a vote");
        return voter.feedback;
    }

    function getTotalVotes() public view returns(uint){
        return VoteNo;
    }

    function getSpecficCandidateVotes(address _candidate) public view returns(uint){
        uint Votes = 0;
        require(candidateId[_candidate] > 0, "Candidate does not exist");
        Votes = candidates[candidateId[_candidate] - 1].votes;
        return Votes;
    }
}
