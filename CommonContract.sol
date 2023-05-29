// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CommonContract {
    enum ActionType {
        Ban,
        AssignRole,
        PromoteUser,
        DemoteUser,
        OtherAction
    }

    struct Decision {
        address moderator;
        address user;
        ActionType action;
        uint256 timestamp;
        uint256 appealDeadline;
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

    modifier onlyRegisteredUser() {
        // find role
        uint256 role = userRoles[msg.sender];
        require(
            role > 0 && role < roleLevels.length,
            "Only registered users can perform this action"
        );
        _;
    }

    modifier notBanned() {
        require(!bannedUsers[msg.sender], "User is banned");
        _;
    }

    function isUserAllowed(address _user) internal view returns (bool) {
        uint256 role = userRoles[_user];
        if (role > 0 && role < roleLevels.length) {
            return false;
        }
        return true;
        // return roles[userRoles[_user]] == true;
    }

    modifier onlyUser() {
        require(isUserAllowed(msg.sender), "User is not allowed");
        _;
    }

    address[] public userList;
    uint256 quorum = (userList.length / 2) + 1;
    mapping(address => uint256) public userRoles;
    mapping(address => bool) public bannedUsers;
    mapping(string => bool) public roles;
    mapping(address => uint256) public previousUserRoles;
    string[] public roleLevels;

    function initializeRoles() internal {
        roles["Visitor"] = true;
        roleLevels.push("Visitor"); // 0

        roles["Admin"] = true;
        roleLevels.push("Admin"); // 1

        roles["User"] = true;
        roleLevels.push("User"); // 2

        roles["Moderator"] = true;
        roleLevels.push("Moderator"); // 3

        roles["GlobalModerator"] = true;
        roleLevels.push("GlobalModerator"); // 4

        roles["Collaborator"] = true;
        roleLevels.push("Collaborator"); // 5
    }
}
