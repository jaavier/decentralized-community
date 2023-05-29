// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CommonContract.sol";
import "./DecisionsContract.sol";
import "./UsersContract.sol";

contract CommunityContract is CommonContract, DecisionsContract, UsersContract {
    address public admin;
    mapping(address => bool) public admins;

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Only the contract admin can execute this function"
        );
        _;
    }

    constructor() {
        admin = msg.sender;
        admins[msg.sender] = true;
        userRoles[msg.sender] = Role.Admin;
        userList.push(msg.sender);
    }

    function addAdmin(address _newAdmin) public onlyAdmin {
        admins[_newAdmin] = true;
        userRoles[_newAdmin] = Role.Admin;
        userList.push(_newAdmin);
    }

    function createRole(address _user, Role _role) public onlyAdmin {
        require(_role != Role.User, "Cannot create User role");
        userRoles[_user] = _role;
    }

    function assignRole(address _user, Role _role) public onlyAdmin {
        require(_role != Role.User, "Cannot assign User role");
        require(userRoles[_user] != Role.User, "User does not exist");
        require(userRoles[_user] != Role.Admin, "Cannot change admin role");

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

    function banUser(address _user) public onlyAdmin {
        require(userRoles[_user] != Role.Admin, "Cannot ban admin");
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
}
