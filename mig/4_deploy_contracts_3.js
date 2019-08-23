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


module.exports = (deployer, network, accounts) => {
    KMXAdminCenter.deployed()
    .then((adminInstance)=>{
        KMX.deployed()
        .then((instance)=>{
            instance.setKMXAdminCenter(adminInstance.address);
            adminInstance.initAdminCenter(instance.address);
        });
    });
};