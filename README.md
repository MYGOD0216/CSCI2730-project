# CSCI2730-project

**_Topic: Blackchain voting system_**

Code: **voting.sol** inside contract

Group member: Yang Yufeng(1155194222), Li Chak Man(1155194613)

Description: We develop the voting system base on the lab example to add more function and modify some original rule. We hope to imitate the real life voting system. 

**_New function:_**<br/> 

- restartElection：restart the election if all candidate agree

- realTimeVote：show the current vote distribution

- voteChange：allow the voter to change their vote before the end of election

- voteRevoke：allow the voter to revoke their vote before the end of election

- votedVoters：List the voters who have voted already

- eligibleVoters：List the voters who are eligible to vote

- voterDelegate: Voter can assign their vote to a person who is not either candidate or voter in the election

- voteAsDelegate: Persin delegare the voter to vote

- VoteCandidateWFB: Voters are allowed to vote with a feedback in string. For instance, they can leave the reaon of choosing candidate.

- anonymousVote: Voters are allowed to vote with their address being hashed by keccak256 hash function. It is guaranteed that they will not be tracked by any     
  function.

- getRecentVoter: Track the most recent voter who does not use the annoymous voting.

- getTotalVotes: To return the total number of votes by all voters in any time.

- getFeedBack: To get feedback from voter who vote for feedback.

**_Modify:_**

-  Candidate have to get over 50% of vote in order to win 

- endElection: can be used for multiple time as there is restartElection
