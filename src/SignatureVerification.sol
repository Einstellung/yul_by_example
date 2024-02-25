// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract SignatureVerification {
    function splitSignature(bytes memory signature) public pure returns (
        bytes32 r,
        bytes32 s,
        uint8 v
    ) {
        // Signatures are 65 bytes in length. r => 32, s => 32, v => 1.
        // Although some signatures can be packed into 64 bytes.
        if (signature.length != 65) revert();

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            // calculate `v` by taking the first byte of the third 32-byte segment
            v := byte(0, mload(add(signature, 0x60)))
        }
    }

    function verifySignature(
        address signer,
        bytes32 hash,
        bytes memory sig
    ) public pure returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(sig);
        // `ecrecover` is a build-in Eth function that can recover the address associated with the public key
        // from the signature(r,s,v) and the original hash
        address recovered = ecrecover(hash, v, r, s);

        return (recovered != address(0) && recovered == signer);
    }
}
