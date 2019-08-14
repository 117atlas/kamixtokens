const KMX = artifacts.require("KMX");
const KMXStable = artifacts.require("KMXStable");
const KMXAdminCenter = artifacts.require("KMXAdminCenter");
const KMXStableMarket = artifacts.require("KMXStableMarket");
const KMXLibrary = artifacts.require("KMXLibrary");
const KMXStableMarketLibrary = artifacts.require("KMXStableMarketLib");
const SafeMath = artifacts.require("SafeMath");
const StringParser = artifacts.require("StringParser");
const AddressUtils = artifacts.require("AddressUtils");
const SafeKMXStableTokenForMarket = artifacts.require("SafeKMXStableTokenForMarket");
const SafeKMXTokenForAdmin = artifacts.require("SafeKMXTokenForAdmin");
const SafeKMXToken = artifacts.require("SafeKMXToken");
const AdminLibrary = artifacts.require("AdminLibrary");
const Web3 = require('web3');
const web3 = new Web3("http://localhost:7545");

module.exports = (deployer, network, accounts) => {
    deployer.link(AddressUtils, KMXStableMarket);
    deployer.link(StringParser, KMXStableMarket);
    deployer.link(SafeMath, KMXStableMarket);
    deployer.link(KMXStableMarketLibrary, KMXStableMarket);
    deployer.link(SafeKMXStableTokenForMarket, KMXStableMarket);
    deployer.deploy(KMXStableMarket, KMXStable.address, {value: web3.utils.toWei('1', 'ether')})
    .then(()=>KMXStableMarket.deployed())
    .then((marketInstance)=>{
        KMXStable.deployed()
        .then((instance)=>{
            instance.setMarketContractAddress(marketInstance.address);
        });
    });
}