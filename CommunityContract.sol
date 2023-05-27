// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CommunityContract {
    enum Role {
        Admin,
        Moderator,
        GlobalModerator,
        Collaborator,
        User
    }

    enum ActionType {
        Ban,
        AssignRole,
        OtherAction
    }

    address public admin;
    mapping(address => bool) public admins;
    mapping(address => bool) public bannedUsers;
    mapping(address => Role) public userRoles;
    Decision[] public decisions;
    AppealVote[] public appealVotes;
    mapping(uint256 => VoteResult) public appealVoteResults;

    struct Decision {
        address moderator;
        address user;
        ActionType action;
        uint256 timestamp;
        bool appealed;
    }

    struct AppealVote {
        uint256 decisionIndex;
        uint256 votesInFavor;
        uint256 votesAgainst;
    }

    struct VoteResult {
        uint256 votesInFavor;
        uint256 votesAgainst;
    }

    mapping(address => mapping(uint256 => bool)) public hasVoted;

    constructor() {
        admin = msg.sender;
        admins[msg.sender] = true;
        userRoles[msg.sender] = Role.Admin;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Only the contract admin can execute this function"
        );
        _;
    }

    modifier notBanned() {
        require(!bannedUsers[msg.sender], "User is banned");
        _;
    }

    modifier onlyRegisteredUser() {
        require(
            userRoles[msg.sender] != Role.User,
            "Only registered users can perform this action"
        );
        _;
    }

    modifier validDecisionIndex(uint256 _decisionIndex) {
        require(_decisionIndex < decisions.length, "Invalid decision index");
        _;
    }

    modifier validAppealIndex(uint256 _appealIndex) {
        require(_appealIndex < appealVotes.length, "Invalid appeal index");
        _;
    }

    function addAdmin(address _newAdmin) public onlyAdmin {
        admins[_newAdmin] = true;
        userRoles[_newAdmin] = Role.Admin;
    }

    function createRole(address _user, Role _role) public onlyAdmin {
        require(_role != Role.User, "Cannot create User role");
        userRoles[_user] = _role;
    }

    function registerUser() public notBanned {
        require(
            userRoles[msg.sender] == Role.User,
            "User is already registered"
        );
        userRoles[msg.sender] = Role.User;
    }

    function banUser(address _user) public onlyAdmin {
        bannedUsers[_user] = true;

        Decision memory newDecision = Decision({
            moderator: msg.sender,
            user: _user,
            action: ActionType.Ban,
            timestamp: block.timestamp,
            appealed: false
        });
        decisions.push(newDecision);
    }

    function assignRole(address _user, Role _role) public onlyAdmin {
        require(_role != Role.User, "Cannot assign User role");
        require(userRoles[_user] != Role.User, "User does not exist");

        Decision memory newDecision = Decision({
            moderator: msg.sender,
            user: _user,
            action: ActionType.AssignRole,
            timestamp: block.timestamp,
            appealed: false
        });
        decisions.push(newDecision);

        userRoles[_user] = _role;
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
