// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library DomainUtils {
    
    function stripProtocol(string memory domain) internal pure returns (string memory) {
        bytes memory httpsPrefix = "https://";
        bytes memory httpPrefix = "http://";
        
        if (hasPrefix(domain, httpsPrefix)) {
            return substring(domain, 8, bytes(domain).length);
        } else if (hasPrefix(domain, httpPrefix)) {
            return substring(domain, 7, bytes(domain).length);
        }
        return domain;
    }

    function extractParentDomain(string memory domain) internal pure returns (string memory) {
        uint lastDot;
        uint secondLastDot;
        
        lastDot = indexOf(domain, bytes1('.'), 0);
        if (lastDot == type(uint256).max) return ""; 

        secondLastDot = indexOf(domain, bytes1('.'), lastDot + 1);
        if (secondLastDot == type(uint256).max) {
            return substring(domain, lastDot + 1, bytes(domain).length);
        }
        return substring(domain, secondLastDot + 1, bytes(domain).length);
    }

    function hasPrefix(string memory _string, bytes memory _prefix) internal pure returns (bool) {
        bool isEqual = true;
        
        assembly {
            let strLen := mload(_string)
            let prefixLen := mload(_prefix)
            
            if lt(strLen, prefixLen) {
                isEqual := 0
            }
            
            for {let i := 0} lt(i, prefixLen) {i := add(i, 1)} {
                if iszero(eq(mload(add(_string, i)), mload(add(_prefix, i)))) {
                    isEqual := 0
                    i := prefixLen
                }
            }
        }
        
        return isEqual;
    }

    function substring(string memory _string, uint _start, uint _end) internal pure returns (string memory result) {
        bytes memory tempResult = new bytes(_end - _start);
        
        assembly {
            for {let i := _start} lt(i, _end) {i := add(i, 1)} {
                mstore(add(tempResult, sub(i, _start)), mload(add(_string, i)))
            }
        }
        
        return string(tempResult);
    }

    function indexOf(string memory _string, bytes1 _value, uint _start) internal pure returns (uint index) {
        index = type(uint256).max;
        assembly {
            let len := mload(_string)
            for {let i := _start} lt(i, len) {i := add(i, 1)} {
                if eq(mload(add(_string, i)), _value) {
                    index := i
                    i := len
                }
            }
        }
    }
}
