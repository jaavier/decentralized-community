// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CommonContract.sol";

contract UsersContract is CommonContract {
    function registerUser() public notBanned {
        require(
            userRoles[msg.sender] == Role.Visitor,
            "User is already registered"
        );
        userRoles[msg.sender] = Role.User;
        userList.push(msg.sender);
    }

    function getUsers(Role _role) public view returns (address[] memory) {
        uint256 numUsers = userList.length;
        address[] memory addresses = new address[](numUsers);
        uint256 count = 0;

        for (uint256 i = 0; i < numUsers; i++) {
            if (userRoles[userList[i]] == _role) {
                addresses[count] = userList[i];
                count++;
            }
        }

        // Redimensionar el arreglo para eliminar las posiciones no utilizadas
        assembly {
            mstore(addresses, count)
        }

        return addresses;
    }
}