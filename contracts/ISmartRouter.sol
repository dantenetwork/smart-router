// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISmartRouter {
    function submitToPara(bytes memory payload) external;
    function submitToOutside(bytes memory payload) external;
}
