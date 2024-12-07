# CSCI2730-project

**_Topic: Blackchain voting system_**

Code: **voting.sol** inside contract

Group member: Yang Yufeng(1155194222), 

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

**_Modify:_**

-  Candidate have to get over 50% of vote in order to win 

- endElection: can be used for multiple time as there is restartElection
