// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CommonContract.sol";

contract UsersContract is CommonContract {
    function registerUser() public notBanned {
        require(
            keccak256(bytes(roleLevels[userRoles[msg.sender]])) ==
                keccak256(bytes("Visitor")),
            "User is already registered"
        );
        userRoles[msg.sender] = 1;
        userList.push(msg.sender);
    }

    function getUsers(string memory _role)
        public
        view
        returns (address[] memory)
    {
        uint256 numUsers = userList.length;
        address[] memory addresses = new address[](numUsers);
        uint256 count = 0;

        for (uint256 i = 0; i < numUsers; i++) {
            if (
                keccak256(bytes(roleLevels[userRoles[userList[i]]])) ==
                keccak256(bytes(_role))
            ) {
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
