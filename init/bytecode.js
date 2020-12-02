const KMXJson = require('../build/contracts/KMX.json');
const KMXStableJson = require('../build/contracts/KMXStable.json');
const KMXAdminCenterJson = require('../build/contracts/KMXAdminCenter.json');
const KMXStableMarketJson = require('../build/contracts/KMXStableMarket.json');

function sizes (name) {
    var abi = require("../build/contracts/" + name + ".json");
    var size = (abi.bytecode.length / 2) - 1 ;
    var deployedSize = (abi.deployedBytecode.length / 2) - 1 ;
    return {name, size, deployedSize};
}

function fmt(obj, div) {
    if (div == null) div = 1;
    return `${obj.name} --> Size : ${obj.size/div}, Deployed size : ${obj.deployedSize/div}` ;
}

const bytecode = function(){
    var l = require('fs').readdirSync("./build/contracts");
    l.forEach(function (f) {
        var name = f.replace(/.json/, '') ;
        var sz = sizes(name) ;
        console.log(fmt(sz)) ;
    });
}

const LIMIT = 1*1024 ;

bytecode();