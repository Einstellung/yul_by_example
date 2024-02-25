// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Showcase the use of keccak256 for hashes.
contract Hash {
    function hash(uint256 a, uint256 b) public pure returns (bytes32) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            mstore(0x00, keccak256(0x00, 0x40))
            return(0x00, 0x20)
        }
    }

    /// @notice Due to Yul structure, ABI.encode is preferred, but encodePacked isn't.
    // this function is equivalent of the Solidity `abi.encode` operation and hash the result.
    function hashABIEncode(string memory s) public pure returns (bytes32) {
        assembly {
            // set up the memory with a starting offset of the data to hash. In ABI encoding the first 32 bytes of the encoded data represent
            // the offset to the actual data. 0x20 is 32 hexadecimal indicating the data starts 32 bytes into the encoded structure.
            mstore(0x00, 0x20)
            // load the length of string(this code design require string is less than 32 bytes) and store it at position 0x20 in memory
            mstore(0x20, mload(s))
            // `s` itself doesn't contain the string but the length of the string. Therefore the string actually starts at `s + 0x20`
            // add(s, 0x20) points to the start of the actual string data.
            mstore(0x40, mload(add(s, 0x20)))
            mstore(0x00, keccak256(0x00, 0x60))
            return(0x00, 0x20)
        }
    }

    function padStringTo32ByteBytes(string memory s) public pure returns (bytes memory) {
        bytes32 str = bytes32(bytes(s));
        bytes memory b = new bytes(32);

        for (uint8 i; i < 32;) {
            b[i] = str[i];
            unchecked { ++i; }
        }

        return b;
    }
}
