// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Checks if an address is a contract or not.
contract IsContract {
    function isContract(address _address) public view returns (bool _isContract) {
        assembly {
            // `extcodesize` opcode is used to get the size of a contract's code stored at a specific address. The size is measured in bytes.
            // If the address does not contain a contract, or if the contract has been self-destructed, `extodesize` returns 0
            let size := extcodesize(_address)

            switch size
            case 0 {
                _isContract := 0x00
            } default {
                _isContract := 0x01
            }
        }
    }
}
