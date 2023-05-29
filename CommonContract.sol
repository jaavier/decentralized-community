// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CommonContract {
    enum Role {
        Visitor,
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

    modifier onlyRegisteredUser() {
        require(
            userRoles[msg.sender] != Role.User,
            "Only registered users can perform this action"
        );
        _;
    }

    modifier notBanned() {
        require(!bannedUsers[msg.sender], "User is banned");
        _;
    }

    address[] public userList;
    mapping(address => Role) public userRoles;
    mapping(address => bool) public bannedUsers;
}