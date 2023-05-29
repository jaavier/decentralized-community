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
        notBanned
    {
        Decision storage decision = decisions[_decisionIndex];
        require(!decision.appealed, "Decision already appealed");

        decision.appealed = true;
        decision.appealDeadline = block.timestamp + 1 weeks;

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

    function processDecision(uint256 _decisionIndex)
        public
        validDecisionIndex(_decisionIndex)
    {
        Decision memory decision = decisions[_decisionIndex];
        require(decision.appealed, "Decision has not been appealed");
        require(
            block.timestamp >= decision.appealDeadline,
            "Voting period has not ended"
        );

        VoteResult memory result = appealVoteResults[_decisionIndex];
        uint256 votesInFavor = result.votesInFavor;
        uint256 votesAgainst = result.votesAgainst;

        if (votesAgainst > votesInFavor) {
            // Revert the decision if the votes against are greater than votes in favor
            // Implement the necessary logic here to revert the decision (e.g., remove the ban)

            // Reset the decision as it has been processed
            decision.appealed = false;
            if (decision.action == ActionType.Ban) {
                bannedUsers[decision.user] = false;
            } else if (decision.action == ActionType.AssignRole) {
                userRoles[decision.user] = previousUserRoles[decision.user];
            }
            delete appealVotes[_decisionIndex];
            delete appealVoteResults[_decisionIndex];
        } else {
            // Implement the necessary logic here to execute the decision (e.g., execute the ban)
        }
    }

    function updateAppealVoteResult(uint256 _appealIndex) internal {
        AppealVote storage appealVote = appealVotes[_appealIndex];
        VoteResult storage result = appealVoteResults[_appealIndex];
        result.votesInFavor = appealVote.votesInFavor;
        result.votesAgainst = appealVote.votesAgainst;
    }

    function getDecision(uint256 _decisionIndex)
        public
        view
        validDecisionIndex(_decisionIndex)
        onlyUser
        returns (
            address,
            address,
            CommonContract.ActionType,
            uint256,
            bool
        )
    {
        Decision storage decision = decisions[_decisionIndex];
        return (
            decision.moderator,
            decision.user,
            decision.action,
            decision.timestamp,
            decision.appealed
        );
    }

    function getNumDecisions() public view returns (uint256) {
        return decisions.length;
    }

    function getAppeal(uint256 _appealIndex)
        public
        view
        validAppealIndex(_appealIndex)
        onlyUser
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        AppealVote storage appeal = appealVotes[_appealIndex];
        return (appeal.decisionIndex, appeal.votesInFavor, appeal.votesAgainst);
    }

    function getNumAppeals() public view returns (uint256) {
        return appealVotes.length;
    }
}
