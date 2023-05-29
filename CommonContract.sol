// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CommonContract {
    enum ActionType {
        Ban,
        AssignRole,
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
        require(
            keccak256(bytes(userRoles[msg.sender])) !=
                keccak256(bytes("Visitor")),
            "Only registered users can perform this action"
        );
        _;
    }

    modifier notBanned() {
        require(!bannedUsers[msg.sender], "User is banned");
        _;
    }

    function isUserAllowed(address _user) internal view returns (bool) {
        return roles[userRoles[_user]] == true;
    }

    modifier onlyUser() {
        require(isUserAllowed(msg.sender), "User is not allowed");
        _;
    }

    address[] public userList;
    uint256 quorum = (userList.length / 2) + 1;
    mapping(address => string) public userRoles;
    mapping(address => bool) public bannedUsers;
    mapping(string => bool) public roles;
    mapping(address => string) public previousUserRoles;

    function initializeRoles() internal {
        roles["Visitor"] = true;
        roles["Admin"] = true;
        roles["Moderator"] = true;
        roles["GlobalModerator"] = true;
        roles["Collaborator"] = true;
        roles["User"] = true;
    }
}
