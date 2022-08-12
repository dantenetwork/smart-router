const Web3 = require('web3');
const fs = require('fs');
const ethereum = require('./ethereum');

const web3 = new Web3('https://moonbase-alpha.public.blastapi.io');
const crossChainContractAddress = '0x63819128fFb3F84BB2C7B2e41875332ec9D66376';
const nearOCContractAddress = 'a7d1736372266477e0d0295d34ae47622ba50d007031a009976348f954e681fe';
const CHAIN_ID = 1287;

// Test account
let testAccountPrivateKey = fs.readFileSync('.secret').toString();

// router contract address
const smartRouterAddress = '0xA2f022E9777fa9c413f1c48312C2fF9A36Cf4940';

// Load contract abi, and init oc contract object
const smartRouterJson = fs.readFileSync('./build/contracts/SmartRouter.json');
const routerAbi = JSON.parse(smartRouterJson).abi;
const smartRouterContract = new web3.eth.Contract(routerAbi, smartRouterJson);

(async function init() {
  // destination chain name
  const destinationChainName = 'NEAR';

  // OCComputing contract action name
  const submitToParaActionName = 'receiveComputeTask';

  // action each param type
  const receiveTaskParamsType = 'uint256[]';
  const receiveResultParamsType = 'uint256';

  // action abi
  const submitToParaABI = '{"inputs":[{"internalType":"uint256[]","name":"_nums","type":"uint256[]"}],"name":"receiveComputeTask","outputs":[],"stateMutability":"nonpayable","type":"function"}';
    
  // // Register contract info for receiving messages from other chains.
  // await ethereum.sendTransaction(web3, CHAIN_ID, ocContract, 'registerPermittedContract', testAccountPrivateKey, [destinationChainName, nearOCContractAddress, receiveTaskActionName]);
  // await ethereum.sendTransaction(web3, CHAIN_ID, ocContract, 'registerPermittedContract', testAccountPrivateKey, [destinationChainName, nearOCContractAddress, receiveResultActionName]);
  await ethereum.sendTransaction(web3, CHAIN_ID, smartRouterContract, 'registerContractABI', testAccountPrivateKey, [submitToParaActionName, submitToParaABI]);
  // await ethereum.sendTransaction(web3, CHAIN_ID, ocContract, 'registerCallbackAbi', testAccountPrivateKey, [destinationChainName, nearOCContractAddress, destReceiveTaskActionName, receiveResultABI]);
}());
