// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice This function shows how Yul can be used in
///         a fallback function.
///         This function will send 1 wei from contract balance to whoever calls it.
contract Fallback {
    /// @notice If the contract balance finishes, it reverts.
    fallback() external {
        assembly {
            // call(gas(), caller(), value(eth amount(wei)), inOffset, inSize, outOffset, outSize)
            // this line code is same as: (bool success, ) = caller().call{value: 1 wei}("");
            let sent := call(gas(), caller(), 1, 0x00, 0x00, 0x00, 0x00)
            if iszero(sent) {
                revert(0x00, 0x00)
            }
        }
    }

    // Fund contract.
    constructor() payable {}
}
