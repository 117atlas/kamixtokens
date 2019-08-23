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

const adminLibAdd = "0x0dC4109D76381c520a40C7C4d0282B78220F917E";
const safeKmxTokenAdd = "0x760571bedCFA23A037874F19f174fdB29a26F876";
const safeKmxTokenForMarketAdd = "0x024e06bE82d7b9A7Cb4640Aa4e91d3AE184BE94d";
const safeKmxTokenForAdminAdd = "0x6f8c27D9b395f8634B3a0726fDe8595A73644D14";
const AddUtilsAdd = "0x0A334947e84A63E3Dc74e4dB94C9aC6e150a6abd";
const StringParserAdd = "0x59669E9af2d5A558e11F00D1358Df5E23C17BE2d";
const safeMathAdd = "0x74A96f120eC1D24BfE4a4c8f8360bf0FEBb2929A";
const kmxStableMarketLibAdd = "0x7A1C82903DD5b04f276464664d86876f5A576094";
const kmxLibAdd = "0x395A3C25dCB25BFB7232813628FF066c487fA648";

module.exports = (deployer, network, accounts) => {
    deployer.link(AddUtilsAdd, KMXStableMarket);
    deployer.link(StringParserAdd, KMXStableMarket);
    deployer.link(safeKmxTokenAdd, KMXStableMarket);
    deployer.link(kmxStableMarketLibAdd, KMXStableMarket);
    deployer.link(safeKmxTokenForMarketAdd, KMXStableMarket);
    deployer.deploy(KMXStableMarket, KMXStable.address, {value: web3.utils.toWei('0.05', 'ether')})
    .then(()=>KMXStableMarket.deployed())
    .then((marketInstance)=>{
        KMXStable.deployed()
        .then((instance)=>{
            instance.setMarketContractAddress(marketInstance.address);
        });
    });
}