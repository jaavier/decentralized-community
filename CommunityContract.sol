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
        userRoles[msg.sender] = "Admin";
        userList.push(msg.sender);
        initializeRoles();
    }

    function addAdmin(address _newAdmin) public onlyAdmin {
        admins[_newAdmin] = true;
        userRoles[_newAdmin] = "Admin";
        userList.push(_newAdmin);
    }

    function createRole(string memory _role) public onlyAdmin {
        require(roles[_role] == false, "Role already exists");
        roles[_role] = true;
    }

    function assignRole(address _user, string memory _role) public onlyAdmin {
        require(
            keccak256(bytes(_role)) != keccak256(bytes("User")),
            "Cannot assign User role"
        );
        require(
            keccak256(bytes(userRoles[_user])) != keccak256(bytes("User")),
            "User does not exist"
        );
        require(
            keccak256(bytes(userRoles[_user])) != keccak256(bytes("Admin")),
            "Cannot change admin role"
        );

        Decision memory newDecision = Decision({
            moderator: msg.sender,
            user: _user,
            action: ActionType.AssignRole,
            timestamp: block.timestamp,
            appealed: false,
            appealDeadline: 0
        });
        decisions.push(newDecision);

        previousUserRoles[_user] = userRoles[_user];
        userRoles[_user] = _role;
    }

    function banUser(address _user) public onlyAdmin {
        require(
            keccak256(bytes(userRoles[_user])) != keccak256("Admin"),
            "Cannot ban admin"
        );
        bannedUsers[_user] = true;

        Decision memory newDecision = Decision({
            moderator: msg.sender,
            user: _user,
            action: ActionType.Ban,
            timestamp: block.timestamp,
            appealed: false,
            appealDeadline: 0
        });
        decisions.push(newDecision);
    }
}
