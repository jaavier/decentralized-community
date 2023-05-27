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

    struct Decision {
        address moderator;
        address user;
        ActionType action;
        uint256 timestamp;
        bool appealed;
    }

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
}
