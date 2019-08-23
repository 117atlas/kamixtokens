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



module.exports = async function(deployer, network, accounts) {
    /*deployer.deploy(SafeKMXStableTokenForMarket);
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

    /*deployer.link(AddressUtils, KMXStableMarket);
    deployer.link(StringParser, KMXStableMarket);
    deployer.link(SafeMath, KMXStableMarket);
    deployer.link(KMXStableMarketLibrary, KMXStableMarket);
    deployer.link(SafeKMXStableTokenForMarket, KMXStableMarket);
    deployer.deploy(KMXStableMarket, "0x3a7005EfF0BaC205398ed7eBF3A48DA498EC24A1"/*KMXStable.address*///, 
        //{value: web3.utils.toWei('1', 'ether')});

    //deployAll(deployer, network, accounts);

    deployer.then(async () => {
        await deployAsync(deployer, network, accounts);
    });
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

    await deployer.link(AddressUtils, KMX);
    await deployer.link(SafeMath, KMX);
    await deployer.deploy(KMX);

    await deployer.link(AddressUtils, KMXAdminCenter);
    await deployer.link(StringParser, KMXAdminCenter);
    await deployer.link(SafeMath, KMXAdminCenter);
    await deployer.link(KMXLibrary, KMXAdminCenter);
    await deployer.link(SafeKMXTokenForAdmin, KMXAdminCenter);
    await deployer.deploy(KMXAdminCenter, {value: web3.utils.toWei('0.05', 'ether')});

    let kmxStable = await KMXStable.deployed();
    await deployer.link(AddressUtils, KMXStableMarket);
    await deployer.link(StringParser, KMXStableMarket);
    await deployer.link(SafeMath, KMXStableMarket);
    await deployer.link(KMXStableMarketLibrary, KMXStableMarket);
    await deployer.link(SafeKMXStableTokenForMarket, KMXStableMarket);
    await deployer.deploy(KMXStableMarket, kmxStable.address, {value: web3.utils.toWei('0.05', 'ether')});
    let kmxStableMarket = await KMXStableMarket.deployed();
    await kmxStable.setMarketContractAddress(kmxStableMarket.address);

    let kmx = await KMX.deployed();
    let kmxAdminCenter = await KMXAdminCenter.deployed();
    await kmx.setKMXAdminCenter(kmxAdminCenter.address);
    await kmxAdminCenter.initAdminCenter(kmx.address);

    await kmx.setStableToken(kmxStable.address);
    await kmxStable.setKmxToken(kmx.address);
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

    deployer.link(AddUtilsAdd, KMXStable);
    deployer.link(safeMathAdd, KMXStable);
    deployer.link(safeKmxTokenAdd, KMXStable);
    deployer.deploy(KMXStable);

    deployer.link(AddUtilsAdd, KMX);
    deployer.link(safeMathAdd, KMX);
    deployer.deploy(KMX);

    deployer.link(AddUtilsAdd, KMXAdminCenter);
    deployer.link(StringParserAdd, KMXAdminCenter);
    deployer.link(safeMathAdd, KMXAdminCenter);
    deployer.link(kmxLibAdd, KMXAdminCenter);
    deployer.link(safeKmxTokenForAdminAdd, KMXAdminCenter);
    deployer.deploy(KMXAdminCenter, {value: web3.utils.toWei('0.05', 'ether')});
}