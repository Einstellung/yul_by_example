// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice The functions in this contract will be called by the
///         `CallerContract` via means of `call` or `staticcall`.
/// @notice Refer to Calldata.md to see how encodings work.
/// @notice Operations in Assembly overflow!!
contract CalledContract {
    struct Data {
        uint128 x;
        uint128 y;
    }

    string public myString;
    uint256 public bigSum;

    // Basic: Take a number and return the sum of that and a fixed value.
    function add(uint256 i) public pure returns (uint256) {
        return i + 78;
    }

    function multiply(uint8 i, uint8 j) public pure returns (uint256) {
        return uint256(i * j);
    }

    function arraySum(uint256[] calldata arr) public pure returns (uint256) {
        uint256 len = arr.length;
        uint256 sum;

        for (uint256 i; i != len; ) {
            sum = sum + arr[i];
        unchecked { ++i; }
        }

        return sum;
    }

    function setString(string calldata str) public {
        if (bytes(str).length > 31) revert();
        myString = str;
    }

    function structCall(Data memory data) public {
        bigSum = uint256(data.x + data.y);
    }

    fallback() external {}
}


/// @notice CallerContract.
///         It calls the `CalledContract`.
contract CallerContract {
    address _calledContract;
    constructor() {
        _calledContract = address(new CalledContract());
    }

    /// @notice add: 1003e2d2.
    function callAdd(uint256 num) public view returns (uint256) {
        address calledContract = _calledContract;

        assembly {
            mstore(0x00, 0x1003e2d2)
            mstore(0x20, num)

            // read only(not change storage) call to another contract
            let success := staticcall(gas(), calledContract, 0x1c, 0x24, 0x00, 0x00)

            if iszero(success) {
                revert (0x00, 0x00)
            }

            returndatacopy(0x00, 0x00, returndatasize())
            return(0x00, returndatasize())
        }
    }

    /// @notice multiply: 6a7a8e0b
    function callMultiply(uint8 num1, uint8 num2) public view returns (uint256) {
        address calledContract = _calledContract;

        assembly {
            mstore(0x80, 0x6a7a8e0b)
            mstore(0xa0, num1)
            mstore(0xc0, num2)

            // 160-4=156 -> 9c; 32(0x6..) + 32(num1) + 4=68 -> 44;
            let success := staticcall(gas(), calledContract, 0x9c, 0x44, 0x00, 0x00)

            if iszero(success) {
                revert (0x00, 0x00)
            }

            returndatacopy(0x00, 0x00, returndatasize())
            return(0x00, returndatasize())
        }
    }

    /// @notice arraySum: 7c2b11cd
    function callArraySum(
        uint256 num1,
        uint256 num2,
        uint256 num3,
        uint256 num4
    ) public view returns (uint256)
    {
        address calledContract = _calledContract;

        assembly {
            mstore(0x80, 0x7c2b11cd)
            mstore(0xa0, 0x20)
            mstore(0xc0, 0x04)
            mstore(0xe0, num1)
            mstore(0x0100, num2)
            mstore(0x0120, num3)
            mstore(0x0140, num4)

            // 32*6+4=196 -> c4
            let success := staticcall(gas(), calledContract, 0x9c, 0xc4, 0x00, 0x00)

            if iszero(success) {
                revert (0x00, 0x00)
            }

            returndatacopy(0x00, 0x00, returndatasize())
            return(0x00, returndatasize())
        }
    }

    /// @notice setString: 7fcaf666
    function callSetString(string calldata str) public {
        uint8 len = uint8(bytes(str).length);
        if (len > 31) revert();

        address calledContract = _calledContract;
        // When you access strCopy, the first 32 bytes at the starting position of strCopy contain the length of the bytes array.
        bytes memory strCopy = bytes(str);

        assembly {
            // The actual bytes of the string start at an offset of 32 bytes from the start of strCopy, which is why the add(strCopy, 0x20) is used. 
            // It's computing the address in memory where the actual string data begins.
            mstore(0x0200, mload(add(strCopy, 0x20)))

            mstore(0x80, 0x7fcaf666)
            mstore(0xa0, 0x20)
            mstore(0xc0, len)
            mstore(0xe0, mload(0x0200))

            // "7fcaf666" is 4 bytes. others don't know, consider them as 32 bytes. so 32*3+4=100 -> 64
            let success := call(gas(), calledContract, 0, 0x9c, 0x64, 0x00, 0x00)
        }
    }

    function getNewString() public view returns (string memory) {
        return CalledContract(_calledContract).myString();
    }

    function callStructCall(uint128 num1, uint128 num2) public {
        address calledContract = _calledContract;
        bytes4 _selector = CalledContract.structCall.selector;

        assembly {
            mstore(0x9c, _selector)
            mstore(0xa0, num1)
            mstore(0xc0, num2)

            let success := call(gas(), calledContract, 0, 0x9c, 0x44, 0x00, 0x00)
        }
    }

    function getBigSum() public view returns (uint256) {
        return CalledContract(_calledContract).bigSum();
    }
}
