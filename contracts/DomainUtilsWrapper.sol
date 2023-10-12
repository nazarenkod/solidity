// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DomainUtils.sol";

contract DomainUtilsWrapper {

    using DomainUtils for string;

    function stripProtocol(string memory domain) public pure returns (string memory) {
        return domain.stripProtocol();
    }

    function extractParentDomain(string memory domain) public pure returns (string memory) {
        return domain.extractParentDomain();
    }

    function hasPrefix(string memory _string, string memory _prefix) public pure returns (bool) {
        return DomainUtils.hasPrefix(_string, _prefix);
    }

    function substring(string memory _string, uint _start, uint _end) public pure returns (string memory) {
        return DomainUtils.substring(_string, _start, _end);
    }

    function indexOf(string memory _string, bytes1 _value, uint _start) public pure returns (uint) {
        bytes memory stringBytes = bytes(_string);
        return DomainUtils.indexOf(stringBytes, _value, _start, stringBytes.length);
    }

    function lastIndexOf(string memory _string, bytes1 _value, uint _start) public pure returns (uint) {
        bytes memory stringBytes = bytes(_string);
        return DomainUtils.lastIndexOf(stringBytes, _value, _start, stringBytes.length);
    }
}
