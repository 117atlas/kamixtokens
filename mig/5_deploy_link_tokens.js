const KMX = artifacts.require("KMX");
const KMXStable = artifacts.require("KMXStable");

module.exports = (deployer, networks, accounts) => {
    KMX.deployed()
    .then((kmx)=>{
        KMXStable.deployed()
        .then((kmxStable)=>{
            kmx.setStableToken(kmxStable.address);
            kmxStable.setKmxToken(kmx.address);
        });
    });
};  