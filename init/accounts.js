require('dotenv').config();
const Vars = require('./vars');
const Web3 = require('web3');
const Tx = require('ethereumjs-tx');
const provider = new Web3.providers.HttpProvider(Vars.providers.ROPSTEN);
const web3 = new Web3(provider);
const BN = require('bn.js');
const DECI = new BN("1000000000000000000", 10);
web3.eth.defaultAccount = Vars.accounts.test.ZERO;

const createEthAccount = async function(){
    let acc = await web3.eth.accounts.create();
    console.log(acc.address);
}

createEthAccount();