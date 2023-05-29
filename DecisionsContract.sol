// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CommonContract.sol";

contract DecisionsContract is CommonContract {

    Decision[] public decisions;
    AppealVote[] public appealVotes;

    mapping(uint256 => VoteResult) public appealVoteResults;
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    modifier validAppealIndex(uint256 _appealIndex) {
        require(_appealIndex < appealVotes.length, "Invalid appeal index");
        _;
    }
    
    modifier validDecisionIndex(uint256 _decisionIndex) {
        require(_decisionIndex < decisions.length, "Invalid decision index");
        _;
    }

    function appealDecision(uint256 _decisionIndex)
        public
        validDecisionIndex(_decisionIndex)
    {
        Decision storage decision = decisions[_decisionIndex];
        require(
            decision.user == msg.sender,
            "Only the affected user can appeal"
        );
        require(!decision.appealed, "Decision already appealed");

        decision.appealed = true;

        initializeAppealVote(_decisionIndex);
    }

    function voteInAppeal(uint256 _appealIndex, bool _inFavor)
        public
        validAppealIndex(_appealIndex)
        onlyRegisteredUser
    {
        AppealVote storage appealVote = appealVotes[_appealIndex];
        require(!hasVoted[msg.sender][_appealIndex], "User has already voted");

        if (_inFavor) {
            appealVote.votesInFavor++;
        } else {
            appealVote.votesAgainst++;
        }
        hasVoted[msg.sender][_appealIndex] = true;

        updateAppealVoteResult(_appealIndex);
    }

    function getAppealVoteResults(uint256 _appealIndex)
        public
        view
        validAppealIndex(_appealIndex)
        returns (uint256, uint256)
    {
        VoteResult storage result = appealVoteResults[_appealIndex];
        return (result.votesInFavor, result.votesAgainst);
    }

    function initializeAppealVote(uint256 _decisionIndex) internal {
        AppealVote memory newAppealVote;
        newAppealVote.decisionIndex = _decisionIndex;
        newAppealVote.votesInFavor = 0;
        newAppealVote.votesAgainst = 0;

        appealVotes.push(newAppealVote);

        updateAppealVoteResult(appealVotes.length - 1);
    }

    function updateAppealVoteResult(uint256 _appealIndex) internal {
        AppealVote storage appealVote = appealVotes[_appealIndex];
        VoteResult storage result = appealVoteResults[_appealIndex];
        result.votesInFavor = appealVote.votesInFavor;
        result.votesAgainst = appealVote.votesAgainst;
    }
}