// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract SendEther {

    constructor() payable {}
    
    function transferEther(uint256 amount, address to) external {
        assembly {
            // `(bool success, ) = to().call{value: amount}("")
            let s := call(gas(), to, amount, 0x00, 0x00, 0x00, 0x00)
            if iszero(s) {
                revert(0x00, 0x00)
            }
        }
    }

}
