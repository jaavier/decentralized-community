# CommunityContract

Smart Contract for managing a web3 community.

## Description

CommunityContract is a Solidity smart contract designed to facilitate the management of an online community within the web3 ecosystem. It provides functionality for role assignment, user registration, moderation actions, and appeal mechanisms.

The contract allows for the creation of different roles such as Admin, Moderator, Global Moderator, Collaborator, and User. The admin, who initially deploys the contract, has the authority to add other admins, create roles, ban users, and assign roles to community members. Users can register themselves within the community and participate according to their assigned roles.

The contract also includes a decision tracking system, where each moderation action, such as banning a user or assigning a role, is recorded with details of the moderator, affected user, action type, timestamp, and appeal status. Users have the ability to appeal decisions made against them, providing a mechanism for dispute resolution.

## Contract Functions

### addAdmin

```solidity
function addAdmin(address _newAdmin) public onlyAdmin
```

Adds a new admin to the community.

- `_newAdmin`: The address of the new admin to be added.

### createRole

```solidity
function createRole(address _user, Role _role) public onlyAdmin
```

Creates a new role and assigns it to a user.

- `_user`: The address of the user to assign the new role.
- `_role`: The role to be assigned to the user.

### registerUser

```solidity
function registerUser() public notBanned
```

Allows a user to register within the community as a regular user.

### banUser

```solidity
function banUser(address _user) public onlyAdmin
```

Bans a user from the community.

- `_user`: The address of the user to be banned.

### assignRole

```solidity
function assignRole(address _user, Role _role) public onlyAdmin
```

Assigns a role to a user.

- `_user`: The address of the user to assign the role.
- `_role`: The role to be assigned to the user.

### appealDecision

```solidity
function appealDecision(uint256 _decisionIndex) public
```

Allows the affected user to appeal a decision made against them.

- `_decisionIndex`: The index of the decision to be appealed.

## Usage

1. Deploy the CommunityContract smart contract on the desired Ethereum network.
2. The deployer of the contract becomes the initial admin.
3. Use the `addAdmin` function to add additional admins as needed.
4. Use the `createRole` function to create custom roles and assign them to users.
5. Users can register themselves within the community using the `registerUser` function.
6. Admins can use the `banUser` function to ban users from the community.
7. Admins can assign roles to users using the `assignRole` function.
8. Users can appeal decisions made against them by calling the `appealDecision` function.

## License

This project is licensed under the [MIT License](LICENSE).