// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CrossChain/ContractBase.sol";
import "./XCM/XcmTransactor.sol";
import "./ISmartRouter.sol";

// `Greetings` is an example of multi-chain services with necessary implementations in `ContractBase`, without which the user defined contract cannot work.
// And besides, `registerDestnContract` and `registerPermittedContract` are templete implementations make the management of some user defined informations easier.
contract SmartRouter is ContractBase, ISmartRouter {
    // Destination contract info
    struct DestnContract {
        string contractAddress; // destination contract address
        string funcName; // destination contract action name
        bool used;
    }

    // Cross-chain destination contract map
    mapping(string => mapping(string => DestnContract)) public destnContractMap;

    // Cross-chain permitted contract map
    mapping(string => mapping(string => string)) public permittedContractMap;

    // Store context of cross chain contract
    // SimplifiedMessage public context;

    address XcmTransactorPrecompileAddress = 0x0000000000000000000000000000000000000806;
    event DataDecoded( uint para_id, bytes inner_call);
    bytes[] public out_queue;

    ///////////////////////////////////////////////
    /////    Send messages to other chains   //////
    ///////////////////////////////////////////////

    /**
     * Register destination contract info
     * @param _funcName - function name to be called
     * @param _toChain - destination chain name
     * @param _contractAddress - destination contract address
     * @param _contractFuncName - contract function name
     */
    function registerDestnContract(
        string calldata _funcName,
        string calldata _toChain,
        string calldata _contractAddress,
        string calldata _contractFuncName
    ) external onlyOwner {
        mapping(string => DestnContract) storage map = destnContractMap[_toChain];
        DestnContract storage destnContract = map[_funcName];
        destnContract.contractAddress = _contractAddress;
        destnContract.funcName = _contractFuncName;
        destnContract.used = true;
    }

    ///////////////////////////////////////////////
    ///    Receive messages from other chains   ///
    ///////////////////////////////////////////////

    /**
     * Authorize contracts of other chains to call the functions of this contract
     * @param _chainName - from chain name
     * @param _sender - sender of cross chain message
     * @param _funcName - action name which allowed to be invoked
     */
    function registerPermittedContract(
        string calldata _chainName,
        string calldata _sender,
        string calldata _funcName
    ) external onlyOwner {
        mapping(string => string) storage map = permittedContractMap[
            _chainName
        ];
        map[_funcName] = _sender;
    }

    /**
     * This verify method will be invoked by the CrossChain contract automatically, ensure that only registered contract(registerSourceContract) calls are allowed
     * @param _chainName - chain name of cross chain message
     * @param _funcName - contract action name of cross chain message
     * @param _sender - cross chain message sender
     */
    //  Will be deprecated soon
    function verify(
        string calldata _chainName,
        string calldata _funcName,
        string calldata _sender
    ) public view virtual returns (bool) {
        mapping(string => string) storage map = permittedContractMap[
            _chainName
        ];
        string storage sender = map[_funcName];
        require(
            keccak256(bytes(sender)) == keccak256(bytes(_sender)),
            "Sender does not match"
        );
        return true;
    }

    function submitToPara(bytes memory payload) external override {
        uint8 para_id;
        bytes memory inner_call;
        (para_id, inner_call) = abi.decode(payload, (uint8, bytes));
        emit DataDecoded(para_id, inner_call);
        XcmTransactor(XcmTransactorPrecompileAddress).transact_through_derivative(para_id, 106, 0xFfFFfFff1FcaCBd218EDc0EbA20Fc2308C778080, 1000000000, inner_call);
    }

    function submitToOutside(bytes memory payload) external override {
        out_queue.push(payload);
    }
}
