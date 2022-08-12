// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ISmartRouter.sol";

contract SmartProxy {
    address public smartRouterAdddrss;

    function setSmartRouter(address routerAddress) public {
        smartRouterAdddrss = routerAddress;
    }

    function submitToPara(bytes memory payload) external {
        ISmartRouter(smartRouterAdddrss).submitToPara(payload);
    }

    function submitToOutside(bytes memory payload) external {
        ISmartRouter(smartRouterAdddrss).submitToOutside(payload);
    }
}
