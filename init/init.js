const KMX = artifacts.require("KMX");
const KMXStable = artifacts.require("KMXStable");
const KMXAdminCenter = artifacts.require("KMXAdminCenter");
const KMXStableMarket = artifacts.require("KMXStableMarket");

module.exports = async function() {
    let kmx = await KMX.at("0x9517F4482d6fd7338a2dB1f7ccfd8d7d8cCA03d9");
    let kmxStable = await KMXStable.at("0x3a7005EfF0BaC205398ed7eBF3A48DA498EC24A1");
    let adminCenter = await KMXAdminCenter.at("0x616f86a818Cda4e3b3883cd1e06921f9a0d2B304"); //await KMXAdminCenter.at("0x6350Fe91163363dE1b3A6AFA4CE52ED63A11a0a9");
    let stableMarket = await KMXStableMarket.at("0xE26402e8aB9F6065bD3167e018536cd341787797");  //at("0x7BD76DAf3660595eAA2BaceEe169b7e97C7Cc3aA");      //("0x133308e9aF479B39F11184CAFDaaF675D22d97E6"); //await KMXStableMarket.at("0x6754276E68EaA9a413A924797c6045BbFA0D4D31");
    await kmxStable.setMarketContractAddress(stableMarket.address);
    //await kmx.setKMXAdminCenter(adminCenter.address);
    //await adminCenter.initAdminCenter(kmx.address);
    //await kmx.setStableToken(kmxStable.address);
    //await kmxStable.setKmxToken(kmx.address);
}