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
        userRoles[msg.sender] = 0;
        userList.push(msg.sender);
        initializeRoles();
    }

    function addAdmin(address _newAdmin) public onlyAdmin {
        admins[_newAdmin] = true;
        userRoles[_newAdmin] = 0;
        userList.push(_newAdmin);
    }

    function createRole(string memory _role) public onlyAdmin {
        require(roles[_role] == false, "Role already exists");
        roles[_role] = true;
        roleLevels.push(_role);
    }

    function assignRole(address _user, uint256 _role) public onlyAdmin {
        uint256 actualRole = userRoles[_user];
        require(
            _role != actualRole,
            "Cannot assign same role"
        );
        require(
            actualRole != 0,
            "User does not exist"
        );
        require(
            actualRole != 1,
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
        uint256 actualRole = userRoles[_user];
        require(
            actualRole != 1,
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
