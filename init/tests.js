const KMXJson = require('../build/contracts/KMX.json');
const KMXStableJson = require('../build/contracts/KMXStable.json');
const KMXAdminCenterJson = require('../build/contracts/KMXAdminCenter.json');
const KMXStableMarketJson = require('../build/contracts/KMXStableMarket.json');
const Web3 = require('web3');
require('dotenv').config();
const Tx = require('ethereumjs-tx');
const provider = new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/a375cbadab474382be7264c909333b6e");
const web3 = new Web3(provider);
const BN = require('bn.js');
const DECI = new BN("1000000000000000000", 10);

const account0 = "0x33BddEB6c4CF1b589ce48e4D383F6521aA089481";
const account1 = "0xf7CC25a9028BF1630166b28D91ea30aF3216cDb1";
const account2 = "0xceFEa4F6B3eC949F5b74eE4095c1AD8DDd96920C";
const account3 = "0x2d8dFDEE98EA87411E8c815f0a74Ad4cF2323264";
const account4 = "0x3B30bF5158DbE244B11925E5127E2c0D16aE4DE8";
const account5 = "0x829f158A276E5E19d0e496C98fdB19e0a47aaB62";
const account6 = "0xB73E6e40c9AF25c9CcE201CFA4bF1A48a8B10225";
const account7 = "0x37AA1840Cef766cc893AA97c0eC1c21B071592Fd";
const account8 = "0x6B32a0b1715Cc1aA6b01bFd5678Cd5c339a84c5A";
const account9 = "0x36C95f525242E0D127D8E4A8d38b4F5d9A0E9378";
const privateKey0 = Buffer.from('E9585CD442319DD69227F8EBC6D031885D72B27AA0C8DB4B21B3BDB09B8B18E4', 'hex');
const privateKey1 = Buffer.from('8b4315ca7e2b4ef97c59a0c37cb5a8df3202c393addbeda0acbd2426d0f282fd', 'hex');
const privateKey2 = Buffer.from('9dee0678926cc32a76f1ceee005abd1d3ba3ae059b9bd55867cc45e3e7edafbf', 'hex');
const privateKey3 = Buffer.from('37f903b282b5b71c3c8485879b8a5b1a6311c1494354e23911a1b9fe2ecb6563', 'hex');
const privateKey4 = Buffer.from('0e584cff58883f1b357d566aab89bd9a7e92b6dcd832ce62a93ca48a89d52911', 'hex');
const privateKey5 = Buffer.from('00c642db0615944e7243f931af3e323d31e55b35ef67c983be56e421f88f6fa9', 'hex');
const privateKey6 = Buffer.from('8937715327450e2b89a73e866d2ae046e6293e6b15fe6f2b23ffb1602c0d7aa5', 'hex');
const privateKey7 = Buffer.from('cc8bd1ec37b73aaa3ff41d203423db1437b17e443f946c3859d79b726b9abe5d', 'hex');
const privateKey8 = Buffer.from('5878054f14c40985cec2ab8367ec8122d69f0d6c5c6906cda1a57a8cf570d015', 'hex');
const privateKey9 = Buffer.from('16712aeefdb9a0afacae6c0d2f585c5def38e56f76210f6d2b94a2e79435907c', 'hex');

web3.eth.defaultAccount = account0;

const KMX_ADDRESS = "0x9517F4482d6fd7338a2dB1f7ccfd8d7d8cCA03d9";
const KMX_STABLE_ADDRESS = "0x3a7005EfF0BaC205398ed7eBF3A48DA498EC24A1";
const KMX_ADMIN_CENTER_ADDRESS = "0x616f86a818Cda4e3b3883cd1e06921f9a0d2B304"; //"0x6350Fe91163363dE1b3A6AFA4CE52ED63A11a0a9";
const KMX_STABLE_MARKET_ADDRESS = "0xE26402e8aB9F6065bD3167e018536cd341787797"; //"0x7BD76DAf3660595eAA2BaceEe169b7e97C7Cc3aA"; //"0x133308e9aF479B39F11184CAFDaaF675D22d97E6"; //"0x6754276E68EaA9a413A924797c6045BbFA0D4D31";

const kmx = new web3.eth.Contract(KMXJson["abi"], KMX_ADDRESS);
const kmxStable = new web3.eth.Contract(KMXStableJson["abi"], KMX_STABLE_ADDRESS);
const kmxStableMarket = new web3.eth.Contract(KMXStableMarketJson["abi"], KMX_STABLE_MARKET_ADDRESS);
const kmxAdminCenter = new web3.eth.Contract(KMXAdminCenterJson["abi"], KMX_ADMIN_CENTER_ADDRESS);

const sendTransaction = function(sender, key, data, contractAddress, value, callback){
    web3.eth.getTransactionCount(sender, (err, txCount) => {
        console.log(txCount);
        const txObject = {
            nonce: web3.utils.toHex(txCount),
            to: contractAddress,
            value:    web3.utils.toHex(value),
            gasLimit: web3.utils.toHex(6721975),
            gasPrice: web3.utils.toHex(web3.utils.toWei('20', 'gwei')),
            data: data,
            chainId: 3
        };
        const tx = new Tx(txObject);
        tx.sign(key);
        const serializedTx = tx.serialize();
        const raw = "0x" + serializedTx.toString('hex');
        web3.eth.sendSignedTransaction(raw)
        .on('transactionHash', function(hash){
            console.log("Transaction hash : " + hash);
        })
        .on('receipt', function(receipt){
            console.log("Receipt");
            console.log(receipt);
        })
        .on('confirmation', function(confirmationNumber, receipt){ 
            console.log("Confirmation number : " + confirmationNumber);
            if (confirmationNumber === 1) {
                console.log("Transaction confirmed");
                if (callback!=null) callback(1);
            }
        })
        .on('error', function(err){
            console.log(err);
            if (callback!=null) callback(0);
        });
    });
}

const f = function(callback){
    const data = kmx.methods.addAdmin(account1).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const isAdmin = function(token, admin, callback) {
    token.methods.isAdmin(admin).call({from: account0}, (err, res)=>{
        if (err) console.log(err);
        else console.log(res);
        if (callback!=null) callback();
    });
}

const removeAdmin = function(tokenAdd, token, from, key, admin, callback){
    const data = token.methods.removeAdmin(admin).encodeABI();
    sendTransaction(from, key, data, tokenAdd, web3.utils.toWei('0', 'wei'), callback);
}

const frozeAccount = function(tokenAdd, token, from, key, account, callback){
    const data = token.methods.frozeAccount(account).encodeABI();
    sendTransaction(from, key, data, tokenAdd, web3.utils.toWei('0', 'wei'), callback);
}

const isAccountFrozen = function(token, account, callback){
    token.methods.isAccountFrozen(account).call({from: account0}, (err, res)=>{
        if (err) console.log(err);
        else console.log(res);
        if (callback!=null) callback();
    });
}

const sendKMXToUser = function(account, callback){
    let amount = web3.utils.toBN(new BN("1000000", 10).mul(DECI));
    amount = '0x'+amount.toString('hex');
    const data = kmx.methods.sendKMXToUser(account, amount).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const startICO = function(callback){
    const data = kmxAdminCenter.methods.startIco().encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_ADMIN_CENTER_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const buyTokens = function(account, currency, amount, callback){
    const data = kmxAdminCenter.methods.buyICOTokensForAccount(account, currency, amount).encodeABI();
    sendTransaction(account1, privateKey1, data, KMX_ADMIN_CENTER_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const KMXTokensParts = function(part, callback){
    kmxAdminCenter.methods.tokens(part).call({from: account0}, (err, res)=>{
        if (err){
            console.log(err);
            callback(0);
        }
        else{
            callback(res);
        }
    });
}

const takeKMXFromUser = function(account, amount, callback){
    const data = kmx.methods.takeKMXFromUser(account, amount).encodeABI();
    sendTransaction(account1, privateKey1, data, KMX_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
};

const transfer = function(from, fromKey, to, amount, callback) {
    const data = kmx.methods.transfer(to, amount).encodeABI();
    sendTransaction(from, fromKey, data, KMX_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
};



const changeStableTransactionFees = function(token, callback){
    let fees = '0x'+web3.utils.toBN(50).toString('hex');
    const data = token.methods.changeFees(fees).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_STABLE_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const getStableTransactionFees = function(token, callback){
    token.methods.transactionFees().call({from: account0}, (err, res)=>{
        if (err) {
            console.log(err);
            callback(0);
        }
        else callback(res);
    });
}

const totalSupply = function(token, callback){
    token.methods.totalSupply().call({from: account0}, (err, res)=>{
        if (err) {
            console.log(err);
            callback(0);
        }
        else callback(res);
    });
}

const changeMintBurnAllowance = function(callback){
    const data = kmxStable.methods.changeMintBurnAllowance(true).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_STABLE_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const mintStableToken = function(amount, callback) {
    const data = kmxStable.methods.mint(amount).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_STABLE_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const burnStableToken = function(amount, callback) {
    const data = kmxStable.methods.burn(amount).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_STABLE_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const buyKMX1 = function(account, callback) {
    let amount = new BN("300000", 10).mul(DECI);
    amount = '0x'+web3.utils.toBN(amount).toString('hex');
    const data = kmxStableMarket.methods.buy(account, "USD", amount).encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_STABLE_MARKET_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const transferKMX1 = function(from, fromKey, to, amount, callback){
    const data = kmxStable.methods.transfer(to, amount).encodeABI();
    sendTransaction(from, fromKey, data, KMX_STABLE_ADDRESS,  web3.utils.toWei('0', 'wei'), callback);
}

const transferKMX1WithKMX2Fees = function(from, fromKey, to, amount, callback){
    let stbtknPrice = web3.utils.toBN(new BN("2500000000000000000", 10));
    stbtknPrice = '0x'+stbtknPrice.toString('hex');
    const data = kmxStable.methods.kmxStableTokenTransferKMXFees(to, amount, stbtknPrice).encodeABI();
    sendTransaction(from, fromKey, data, KMX_STABLE_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const setExchangeTokensUrl = function(callback){
    const data = kmxStableMarket.methods.setStableTokenPriceUrl("https://young-chamber-62260.herokuapp.com/kmx2priceinkmx1").encodeABI();
    sendTransaction(account0, privateKey0, data, KMX_STABLE_MARKET_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

const getExchangeTokensUrl = function(callback){
    kmxStableMarket.methods.stableTokenPriceUrl().call({from: account0}, (err, res)=>{
        if (err) {
            console.log(err);
            callback(0);
        }
        else callback(res);
    });
}

const exchangeTokens = function(account, accountKey, callback) {
    let amount = new BN("100000", 10).mul(DECI);
    amount = '0x'+web3.utils.toBN(amount).toString('hex');
    const data = kmxStableMarket.methods.buyKMXTokens(amount).encodeABI();
    sendTransaction(account, accountKey, data, KMX_STABLE_MARKET_ADDRESS, web3.utils.toWei('0', 'wei'), callback);
}

let amount = web3.utils.toBN(new BN("100000", 10).mul(DECI));
amount = '0x'+amount.toString('hex');

exchangeTokens(account6, privateKey6, (code)=>{process.exit(0);})

/*const data = kmxAdminCenter.methods.buyICOTokensWithEther().encodeABI();
sendTransaction(account7, privateKey7, data, KMX_ADMIN_CENTER_ADDRESS, web3.utils.toWei('0.2', 'ether'), (code)=>{
    process.exit(0);
});*/

/*
KMXTokensParts('0x'+web3.utils.toBN(30).toString('hex'), (res)=>{
    if (res!==0){
        console.log("Tokens to circ : " + web3.utils.toBN(res).div(DECI) + " KMX2");
        KMXTokensParts('0x'+web3.utils.toBN(12).toString('hex'), (res)=>{
            if (res!==0){
                console.log("Tokens to sold : " + web3.utils.toBN(res).div(DECI) + " KMX2");
                KMXTokensParts('0x'+web3.utils.toBN(11).toString('hex'), (res)=>{
                    if (res!==0){
                        console.log("Remaining tokens : " + web3.utils.toBN(res).div(DECI) + " KMX2");
                    }
                });
            }
        });
    }
});
*/

/*const data = kmxAdminCenter.methods
.changeTokenEthPriceOracleUrl("https://young-chamber-62260.herokuapp.com/ethpriceinkmx2").encodeABI();
sendTransaction(account0, privateKey0, data, KMX_ADMIN_CENTER_ADDRESS, web3.utils.toWei('0', 'wei'), (code)=>{
    if (code !== 0){
        const data = kmxStableMarket.methods.setStableTokenPriceUrl("https://young-chamber-62260.herokuapp.com/kmx2priceinkmx1")
        .encodeABI();
        sendTransaction(account0, privateKey0, data, KMX_STABLE_MARKET_ADDRESS, web3.utils.toWei('0', 'wei'), (code)=>{
            kmxAdminCenter.methods._tknEtherPriceOracleUrl().call({from: account0}, (err, res)=>{
                if (!err) console.log(res);
                kmxStableMarket.methods.stableTokenPriceUrl().call({from: account0}, (err, res)=>{
                    if (!err) console.log(res);
                });
            });
        });
    }
});*/

/*kmxAdminCenter.methods._tknEtherPriceOracleUrl().call({from: account0}, (err, res)=>{
    if (!err) console.log(res);
    kmxStableMarket.methods.stableTokenPriceUrl().call({from: account0}, (err, res)=>{
        if (!err) console.log(res);
    });
});*/

/*kmxStableMarket.methods.kmxStableToken().call({from: account0}, (err, res)=>{
    if (!err) console.log(res);
    kmxStable.methods.marketContractAddress().call({from: account0}, (err, res)=>{
        if (!err) console.log(res);
        kmx.methods.getStableToken().call({from: account0}, (err, res)=>{
            if (!err) console.log(res);
        });
    });
});*/
