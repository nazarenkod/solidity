// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

pragma solidity ^0.8.20;

library DomainUtils {
    
    function stripProtocol(string memory domain) internal pure returns (string memory) {
        if (hasPrefix(domain, "https://")) {
            return substring(domain, 8, bytes(domain).length);
        } else if (hasPrefix(domain, "http://")) {
            return substring(domain, 7, bytes(domain).length);
        }
        return domain;
    }

function extractParentDomain(string memory domain) internal pure returns (string memory) {
    bytes memory domainBytes = bytes(domain);
    uint lastDot = indexOf(domainBytes, bytes1('.'), 0);
    if (lastDot == type(uint256).max) return ""; // No dots means it's already a TLD

    uint secondLastDot = indexOf(domainBytes, bytes1('.'), lastDot + 1);
    if (secondLastDot == type(uint256).max) return substring(domain, lastDot + 1, domainBytes.length); // If there's only one dot, return the portion after that dot

    return substring(domain, secondLastDot + 1, domainBytes.length); // Otherwise, return the portion after the second last dot
}

    function hasPrefix(string memory _string, string memory _prefix) internal pure returns (bool) {
        bytes memory stringBytes = bytes(_string);
        bytes memory prefixBytes = bytes(_prefix);
        if (stringBytes.length < prefixBytes.length) return false;
        for (uint i = 0; i < prefixBytes.length; i++) {
            if (stringBytes[i] != prefixBytes[i]) return false;
        }
        return true;
    }

    function substring(string memory _string, uint _start, uint _end) internal pure returns (string memory) {
        bytes memory result = new bytes(_end - _start);
        for (uint i = _start; i < _end; i++) {
            result[i - _start] = bytes(_string)[i];
        }
        return string(result);
    }

    function indexOf(bytes memory _bytes, bytes1 _value, uint _start) internal pure returns (uint) {
        for (uint i = _start; i < _bytes.length; i++) {
            if (_bytes[i] == _value) return i;
        }
        return type(uint256).max;
    }
}
