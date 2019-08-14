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

module.exports = function(deployer, network, accounts) {
    deployer.deploy(SafeKMXStableTokenForMarket);
    //deployer.deploy(SafeKMXTokenForAdmin);
    deployer.deploy(AddressUtils);
    deployer.deploy(StringParser);
    deployer.deploy(SafeMath);

    deployer.link(SafeMath, KMXStableMarketLibrary);
    //deployer.link(SafeMath, KMXLibrary);
    deployer.deploy(KMXStableMarketLibrary);
    //deployer.deploy(KMXLibrary);

    /*deployer.link(AddressUtils, KMXAdminCenter);
    deployer.link(StringParser, KMXAdminCenter);
    deployer.link(SafeMath, KMXAdminCenter);
    deployer.link(KMXLibrary, KMXAdminCenter);
    deployer.link(SafeKMXTokenForAdmin, KMXAdminCenter);
    deployer.deploy(KMXAdminCenter, {value: web3.utils.toWei('1', 'ether')});*/

    deployer.link(AddressUtils, KMXStableMarket);
    deployer.link(StringParser, KMXStableMarket);
    deployer.link(SafeMath, KMXStableMarket);
    deployer.link(KMXStableMarketLibrary, KMXStableMarket);
    deployer.link(SafeKMXStableTokenForMarket, KMXStableMarket);
    deployer.deploy(KMXStableMarket, "0x3a7005EfF0BaC205398ed7eBF3A48DA498EC24A1"/*KMXStable.address*/, 
        {value: web3.utils.toWei('1', 'ether')});
}

const deploySync = function(deployer, network, accounts){
    if (network === 'unittest') return;

    deployer.deploy(AdminLibrary);
    deployer.deploy(SafeKMXToken);
    deployer.deploy(SafeKMXStableTokenForMarket);
    deployer.deploy(SafeKMXTokenForAdmin);
    deployer.deploy(AddressUtils);
    deployer.deploy(StringParser);
    deployer.deploy(SafeMath);

    deployer.link(SafeMath, KMXStableMarketLibrary);
    deployer.link(SafeMath, KMXLibrary);
    deployer.deploy(KMXStableMarketLibrary);
    deployer.deploy(KMXLibrary);

    deployer.link(AddressUtils, KMXStable);
    deployer.link(SafeMath, KMXStable);
    deployer.link(SafeKMXToken, KMXStable);
    deployer.deploy(KMXStable)
    .then(()=>KMXStable.deployed())
    .then((instance)=>{
        deployer.link(AddressUtils, KMXStableMarket);
        deployer.link(StringParser, KMXStableMarket);
        deployer.link(SafeMath, KMXStableMarket);
        deployer.link(KMXStableMarketLibrary, KMXStableMarket);
        deployer.link(SafeKMXStableTokenForMarket, KMXStableMarket);
        deployer.deploy(KMXStableMarket, instance.address)
        .then(()=>KMXStableMarket.deployed())
        .then((marketInstance)=>{
            instance.setMarketContractAddress(marketInstance.address);
        });
    });

    deployer.link(AddressUtils, KMX);
    deployer.link(SafeMath, KMX);
    deployer.deploy(KMX)
    .then(()=>KMX.deployed())
    .then((instance)=>{
        deployer.link(AddressUtils, KMXAdminCenter);
        deployer.link(StringParser, KMXAdminCenter);
        deployer.link(SafeMath, KMXAdminCenter);
        deployer.link(KMXLibrary, KMXAdminCenter);
        deployer.link(SafeKMXTokenForAdmin, KMXAdminCenter);
        deployer.deploy(KMXAdminCenter)
        .then(()=>KMXAdminCenter.deployed())
        .then((adminInstance)=>{
            instance.setKMXAdminCenter(adminInstance.address)
            .then(()=>{
                adminInstance.initAdminCenter(instance.address);
            });
        });
    });
}

const deployAsync = async function(deployer, network, accounts){
    await deployer.deploy(AdminLibrary);
    await deployer.deploy(SafeKMXToken);
    await deployer.deploy(SafeKMXStableTokenForMarket);
    await deployer.deploy(SafeKMXTokenForAdmin);
    await deployer.deploy(AddressUtils);
    await deployer.deploy(StringParser);
    await deployer.deploy(SafeMath);

    await deployer.link(SafeMath, KMXStableMarketLibrary);
    await deployer.link(SafeMath, KMXLibrary);
    await deployer.deploy(KMXStableMarketLibrary);
    await deployer.deploy(KMXLibrary);

    await deployer.link(AddressUtils, KMXStable);
    await deployer.link(SafeMath, KMXStable);
    await deployer.link(SafeKMXToken, KMXStable);
    await deployer.deploy(KMXStable);
    let kmxStable = await KMXStable.deployed();
    await deployer.link(AddressUtils, KMXStableMarket);
    await deployer.link(StringParser, KMXStableMarket);
    await deployer.link(SafeMath, KMXStableMarket);
    await deployer.link(KMXStableMarketLibrary, KMXStableMarket);
    await deployer.link(SafeKMXStableTokenForMarket, KMXStableMarket);
    await deployer.deploy(KMXStableMarket, kmxStable.address);
    let kmxStableMarket = await KMXStableMarket.deployed();
    await kmxStable.setMarketContractAddress(kmxStableMarket.address);

    await eployer.link(AddressUtils, KMX);
    await deployer.link(SafeMath, KMX);
    await deployer.deploy(KMX);
    let kmx = await KMX.deployed();
    await deployer.link(AddressUtils, KMXAdminCenter);
    await deployer.link(StringParser, KMXAdminCenter);
    await deployer.link(SafeMath, KMXAdminCenter);
    await deployer.link(KMXLibrary, KMXAdminCenter);
    await deployer.link(SafeKMXTokenForAdmin, KMXAdminCenter);
    await deployer.deploy(KMXAdminCenter);
    let kmxAdminCenter = await KMXAdminCenter.deployed();
    await kmx.setKMXAdminCenter(kmxAdminCenter.address);
    await kmxAdminCenter.initAdminCenter(kmx.address);
}

const deployAll = function(deployer, network, accounts){
    deployer.deploy(AdminLibrary);
    deployer.deploy(SafeKMXToken);
    deployer.deploy(SafeKMXStableTokenForMarket);
    deployer.deploy(SafeKMXTokenForAdmin);
    deployer.deploy(AddressUtils);
    deployer.deploy(StringParser);
    deployer.deploy(SafeMath);

    deployer.link(SafeMath, KMXStableMarketLibrary);
    deployer.link(SafeMath, KMXLibrary);
    deployer.deploy(KMXStableMarketLibrary);
    deployer.deploy(KMXLibrary);

    deployer.link(AddressUtils, KMXStable);
    deployer.link(SafeMath, KMXStable);
    deployer.link(SafeKMXToken, KMXStable);
    deployer.deploy(KMXStable);

    deployer.link(AddressUtils, KMX);
    deployer.link(SafeMath, KMX);
    deployer.deploy(KMX);

    deployer.link(AddressUtils, KMXAdminCenter);
    deployer.link(StringParser, KMXAdminCenter);
    deployer.link(SafeMath, KMXAdminCenter);
    deployer.link(KMXLibrary, KMXAdminCenter);
    deployer.link(SafeKMXTokenForAdmin, KMXAdminCenter);
    deployer.deploy(KMXAdminCenter, {value: web3.utils.toWei('1', 'ether')});
}