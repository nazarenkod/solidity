// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library DomainUtils {

    function stripProtocol(string memory domain) internal pure returns (string memory) {
        bytes memory domainBytes = bytes(domain);
        uint len = domainBytes.length;

        if (len == 0) {
            return domain;
        }

        for (uint i = 0; i < len - 1; i++) {
            if (domainBytes[i] == '/' && domainBytes[i + 1] == '/') {
                bytes memory resultBytes = new bytes(len - i - 2);
                for (uint j = i + 2; j < len; j++) {
                    resultBytes[j - i - 2] = domainBytes[j];
                }
                return string(resultBytes);
            }
        }

        return domain;
    }

function extractParentDomain(string memory domain) internal pure returns (string memory) {
    bytes memory domainBytes = bytes(domain);
    uint lastDot = indexOf(domainBytes, bytes1('.'), 0, domainBytes.length);

    if (lastDot == type(uint256).max) return "";

    uint secondLastDot = indexOf(domainBytes, bytes1('.'), 0, lastDot);

    if (secondLastDot == type(uint256).max) {
        return substring(domain, lastDot + 1, domainBytes.length); 
    } else {
        return substring(domain, secondLastDot + 1, lastDot); 
    }
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

function indexOf(bytes memory _bytes, bytes1 _value, uint _start, uint _end) internal pure returns (uint) {
    for (uint i = _start; i < _end; i++) {
        if (_bytes[i] == _value) return i;
    }
    return type(uint256).max;
}

function lastIndexOf(bytes memory _bytes, bytes1 _value, uint _start, uint _end) internal pure returns (uint) {
    for (uint i = _end; i > _start; i--) {
        if (_bytes[i - 1] == _value) return i - 1;
    }
    return type(uint256).max;
}
}
