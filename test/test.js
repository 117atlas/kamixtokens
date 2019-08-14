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
const assert = require('chai').assert;
const truffleAssert = require('truffle-assertions');
const web3 = require('web3');
const Web3 = new web3("http://localhost:7545");

const BN = require('bn.js');

const KMX_TOKEN_ADDRESS = "0x4B5C64D5759c872DC37fA69EedA0c4b338606486";
const KMX_ADMIN_CNTR_ADDRESS = "0x14821940ADb95a029731787110cFF34fe354E8FA";

const STABLE_TOKEN_ADDRESS = "0xcCA673D77Ca8FCD6A84Db8EF961885a05da5A954";
const STABLE_MARKET_ADDRESS = "0xd8c90693bf2512CFA5DE85315bEeaD99eBE93C72";

/** 
 * Account 4 is frozen 
 * Account 5 buys tokens in EUR
 * Account 6 buys tokens in USD
 * Account 7 buys tokens in XAF
*/
contract('Kamix Stable Market', async function(accounts){
    describe('Test Kamix Stable Market', async function(){
        const deci = new BN("1000000000000000000", 10);
        const stbTknPrice = new BN("2500000000000000000", 10);
        it('Get KMX Token', async function(){
            let kmxStable = await KMXStable.at("0xcD77f405063dcCE27537b925f159479be960a48e");
            let kmx = await KMX.at("0xE1a50CF6B60643a7a8f1dB4A535A8157Ae02Eb9B");
            let kmxAdd = await kmxStable.getKmxToken.call();
            let stableAdd = await kmx.getStableToken.call();
            console.log("KMX Token Address : " + kmxAdd + "\nKMX Stable Token Address : " + stableAdd);
        });
    });
});

const testAdminOwner = async function(){
    describe('First test', async function(){
        /*it('Test admin - Step 1', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            await kmx.addAdmin(accounts[1], {from: accounts[0]});
            assert.equal(await kmx.isAdmin.call(accounts[1]), true, "Account 1 is an admin");
            console.log(kmx.address);
        });*/
        /*it('Test admin - Step 2', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            assert.equal(await kmx.isAdmin.call(accounts[1]), true, "Account 1 is an admin");
            await kmx.removeAdmin(accounts[1], {from: accounts[0]});
        });
        it('Test admin - Step 3', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            assert.equal(await kmx.isAdmin.call(accounts[1]), false, "Account 1 is an admin");
        });*/
        it('Test admin - Step 4', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            await kmx.addAdmin(accounts[1], {from: accounts[0]});
            assert.equal(await kmx.isAdmin.call(accounts[1]), true, "Account 1 is an admin");
            console.log(kmx.address);
        });
        it('Test admin - Step 5', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            assert.equal(await kmx.isAdmin.call(accounts[1]), true, "Account 1 is an admin");
            await kmx.renounceAdmin({from: accounts[1]});
        });
        it('Test admin - Step 6', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            assert.equal(await kmx.isAdmin.call(accounts[1]), false, "Account 1 is an admin");
        });
    });
};

const testAccountFroze = async function(){
    describe('Test Account frozenable functionnalities', async function(){
        it('Froze account', async function(){
            let kmx = await KMX.at("0x28Cb59f01016DB7A27Ea7C7b44410D5440e9EB68");
            await kmx.unfrozeAccount(accounts[2], {from: accounts[0]});
            assert.equal(await kmx.isAccountFrozen.call(accounts[2]), false, "Account 2 is not frozen");
        });
    });
};

const testConfigurable = async function(){
    /*it('Token prices', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let eur = await kmx.tokenPrice.call("EUR");
            let usd = await kmx.tokenPrice.call("USD");
            let xaf = await kmx.tokenPrice.call("XAF");
            console.log("Prices: EUR = " + eur + ", USD = " + usd + ", XAF = " + xaf + ".");
        });
        it('Change Token price - Invalid currency', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changePrice(new BN("4520000000000000000", 10), "YEN", {from: accounts[0]});
        });
        it('Change Token price - Not from an admin', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changePrice(new BN("4520000000000000000", 10), "EUR", {from: accounts[1]});
        });
        it('Change Token price - Invalid new price', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changePrice(0, "EUR", {from: accounts[0]});
        });*/
        /*it('Change Token price - Well', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changePrice(new BN("4520000000000000000", 10), "EUR", {from: accounts[0]});
            let eur =  await kmx.tokenPrice.call("EUR");
            assert.equal(eur.toString(10), new BN("4520000000000000000", 10).toString(10), "There was an error");
        });*/
        /*it('Change transaction fees', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changeFees(50000, {from: accounts[0]});
        });
        it('Test getting transaction fees', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let fees = await kmx.transactionFees.call();
            console.log("Fees : " + fees);
            //assert.equal(fees.toString(10), new BN("2", 10).toString(10), "Transaction fees must be 2%");
        });*/
        /*it('Change Token holder - Invalid sender', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changeTokenHolder(accounts[0], {from: accounts[1]});
        });
        it('Change Token holder - Invalid new token holder', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.changeTokenHolder(accounts[0], {from: accounts[0]});
        });
        it('Change Token holder', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let tx = await kmx.changeTokenHolder(accounts[9], {from: accounts[0]});
            truffleAssert.eventEmitted(tx, 'TokenHolderChanged', (ev) => {
                console.log("Old token holder : " + ev.oldTokenHolder + ", New token holder : " + ev.newTokenHolder)
                return ev.oldTokenHolder === accounts[0] && ev.newTokenHolder === accounts[9];
            });
        });*/
        /*it('Get affilied contracts', async function(){
            /*let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            console.log(tokenHolderBalance.toString(10));
            let kmxCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await kmxCenter.initAdminCenter(KMX_TOKEN_ADDRESS);
            //let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            //let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            //console.log(tokenHolderBalance.toString(10));
        });*/
        /*it('Send tokens - Froze account 5', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.frozeAccount(accounts[5], {from: accounts[0]});
            assert.equal(await kmx.isAccountFrozen.call(accounts[5]), true, "Account 5 must be frozen");
        });
        it('Send tokens - not admin 5', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.sendKMXToUser(accounts[5], 0, {from: accounts[1]});
        });
        it('Send tokens - account frozen', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.sendKMXToUser(accounts[5], 0, {from: accounts[0]});
        });
        it('Send tokens - amount is 0', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.sendKMXToUser(accounts[6], 0, {from: accounts[0]});
        });
        it('Send tokens - amount > than token holder balance', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.sendKMXToUser(accounts[6], new BN("150000000000000000000000000", 10), {from: accounts[0]});
        });
        it('Send tokens - amount > than token holder balance', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let tx = await kmx.sendKMXToUser(accounts[6], new BN("1000000000000000000000000", 10), {from: accounts[0]});
            truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                console.log("From : " + ev.from + ", To : " + ev.to + ", Amount : " + ev.value);
                return ev.from === accounts[0] && ev.to === accounts[6];
            });
        });*/
        /*it('Balances after send tokens', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let account6Balance = await kmx.balanceOf.call(accounts[6]);
            assert.equal(account6Balance.toString(10), new BN("1000000000000000000000000", 10).toString(10), "Account 6 balance is 1 millions");
        });
        it('Balances after send tokens - holder', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let account6Balance = await kmx.balanceOf.call(accounts[0]);
            assert.equal(account6Balance.toString(10), new BN("143000000000000000000000000", 10).toString(10), "Account 6 balance is 143 millions");
        });*/
        /*it('Send tokens - amount > than token holder balance', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let tx = await kmx.takeKMXFromUser(accounts[6], new BN("500000000000000000000000", 10), {from: accounts[0]});
            truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
                console.log("From : " + ev.from + ", To : " + ev.to + ", Amount : " + ev.value);
                return ev.from === accounts[0] && ev.to === accounts[6];
            });
        });*/
        /*it('Balances after send tokens', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let account6Balance = await kmx.balanceOf.call(accounts[6]);
            assert.equal(account6Balance.toString(10), new BN("500000000000000000000000", 10).toString(10), "Account 6 balance is 1 millions");
        });
        it('Balances after send tokens - holder', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let account6Balance = await kmx.balanceOf.call(accounts[0]);
            assert.equal(account6Balance.toString(10), new BN("143500000000000000000000000", 10).toString(10), "Account 6 balance is 143 millions");
        });*/
        /*it('Froze account 4', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.frozeAccount(accounts[4], {from: accounts[0]});
            assert.equal(await kmx.isAccountFrozen.call(accounts[4]), true, "Account 5 must be frozen");
        });
        it('Test transfer - sender frozen', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.transfer(accounts[5], 0, {from: accounts[4]});
        });
        it('Test transfer - receiver frozen', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.transfer(accounts[5], 0, {from: accounts[6]});
        });
        it('Test transfer - Token holder sender', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.transfer(accounts[0], 0, {from: accounts[0]});
        });
        it('Test transfer - value 0', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.transfer(accounts[0], 0, {from: accounts[6]});
        });
        it('Test transfer - Valid', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.transfer(accounts[0], new BN("100000000000000000000000", 10), {from: accounts[6]});
        });
        it('Check balances after transfer', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            let account6Balance = await kmx.balanceOf.call(accounts[6]);
            console.log("Holder balance : " + tokenHolderBalance.toString(10) + "\nAccount 6 balance : " + account6Balance.toString(10));
        });
        it('Utilitaries', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let totalSupply = await kmx.totalSupply();
            let name = await kmx.name();
            let symbols = await kmx.symbols();
            let decimals = await kmx.decimals();
            console.log("Total supply : " + totalSupply.toString(10) + "\nName : " + name + "\nSymbols : " + symbols + "\nDecimals : " + decimals.toString(10));
        });*/
};

const sendTokens = async function(){
    /*it('Send 5M To account 6', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            console.log("TKN Holder : " + tokenHolderBalance.toString(10));
            await kmx.sendKMXToUser(accounts[6], new BN("500000000000000000000000"), {from: accounts[0]});
            tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            account6Balance = await kmx.balanceOf.call(accounts[6]);
            console.log("Holder balance : " + tokenHolderBalance.toString(10) + "\nAccount 6 balance : " + account6Balance.toString(10));
        });*/
};

const testKamixToken = () => {
    it('Test transfer from - Approve', async function(){
        let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
        await kmx.approve(accounts[7], new BN("200000000000000000000000", 10), {from: accounts[6]});
        let allowance = await kmx.allowance.call(accounts[6], accounts[7]);
        assert.equal(allowance.toString(10), new BN("200000000000000000000000", 10).toString(10), "Allowance must be 1000000");
    })
    it('Test transfer from - Spender unsufficient funds', async function(){
        let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
        await kmx.transferFrom(accounts[0], accounts[6], new BN("200000000000000000000000", 10), {from: accounts[7]});
    });
    it('Test transfer from - Valid', async function(){
        let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
        await kmx.transferFrom(accounts[0], accounts[6], new BN("100000000000000000000000", 10), {from: accounts[7]});
    });
    it('Check balances after transfer', async function(){
        let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
        let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
        let account6Balance = await kmx.balanceOf.call(accounts[6]);
        let allowance = await kmx.allowance.call(accounts[6], accounts[7]);
        console.log("Holder balance : " + tokenHolderBalance.toString(10) + "\nAccount 6 balance : " + account6Balance.toString(10) + "\nAllowance : " + allowance.toString(10));
    });
};

const testAdminCenterUtils = () => {
    /*it('Oracle url', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let url = await adminCenter._tknEtherPriceOracleUrl();//tokenEthPriceOracleUrl();
            console.log(url);
        });
        it('Buy with ether fees', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let fees = await adminCenter._buyRefundWithEtherFees();//buyRefundWithEtherFees();
            console.log(fees.toString(10));
        });
        it('ICO status', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let icoStatus = await adminCenter.statusIco.call();
            console.log(icoStatus);
        });*/
        /*it('Reserve to sell - exceed reserve funds', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.reserveToSell(new BN("70000000000000000000000000"), {from: accounts[0]});
        });
        it('Reserve to sell - valid', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.reserveToSell(new BN("10000000000000000000000000"), {from: accounts[0]});
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let reserve = await adminCenter.tokens.call(20);
            let circulatinf = await adminCenter.tokens.call(0);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Reserve : " + reserve.toString(10) + "\n" +
                "Circulating : " + circulatinf);
        });*/
        /*it('Sell to reserve - exceed sell funds', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.sellToReserve(new BN("200000000000000000000000000"), {from: accounts[0]});
        });*/
        /*it('Sell to circulation - valid', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.reserveToCirculation(new BN("10000000000000000000000000"), {from: accounts[0]});
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let reserve = await adminCenter.tokens.call(20);
            let circulatinf = await adminCenter.tokens.call(0);
            let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Reserve : " + reserve.toString(10) + "\n" +
                "Circulating : " + circulatinf.toString(10) + "\n" +
                "Token holder balance : " + tokenHolderBalance.toString(10));
        });
        it('circulation to sell - valid', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.circulationToReserve(new BN("10000000000000000000000000"), {from: accounts[0]});
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let reserve = await adminCenter.tokens.call(20);
            let circulatinf = await adminCenter.tokens.call(0);
            let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Reserve : " + reserve.toString(10) + "\n" +
                "Circulating : " + circulatinf.toString(10) + "\n" +
                "Token holder balance : " + tokenHolderBalance.toString(10));
        });*/
};

const testAdminCenterIcoWithFiat = () => {
    /*it('ICO - Froze one account', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.frozeAccount(accounts[4]);
            assert.equal(await kmx.isAccountFrozen.call(accounts[4]), true, "Account 4 must be frozen");
        });
        it('ICO Buy - function is not launched by an admin', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[0], "YEN", 0, {from: accounts[1]});
        });
        it('ICO Buy - account is token holder', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[0], "YEN", 0, {from: accounts[0]});
        });
        it('ICO Buy - account is frozen', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[4], "YEN", 0, {from: accounts[0]});
        });
        it('ICO Buy - ICO is pending', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[5], "YEN", 0, {from: accounts[0]});
        });
        it('ICO Buy - start ico - not by owner', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.startIco({from: accounts[1]});
        });
        it('ICO Buy - start ico - valid', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.startIco({from: accounts[0]});
            let icoStatus = await adminCenter.statusIco.call();
            console.log(icoStatus);
        });
        it('ICO Buy - Invalid currency', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[5], "YEN", 0, {from: accounts[0]});
        });
        it('ICO Buy - amount is 0', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[5], "EUR", 0, {from: accounts[0]});
        });*/
        /*it('ICO Buy - Pause ICO', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.pauseIco({from: accounts[0]});
            let icoStatus = await adminCenter.statusIco.call();
            console.log(icoStatus);
        });
        it('ICO Buy - valid in EUR', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[5], "EUR", new BN("100").mul(deci), {from: accounts[0]});
        });
        it('ICO Buy - Resume ICO', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.continueIco({from: accounts[0]});
            let icoStatus = await adminCenter.statusIco.call();
            console.log(icoStatus);
        });
        it('ICO Buy - valid in EUR', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[5], "EUR", new BN("100").mul(deci), {from: accounts[0]});
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let accountBalance = await kmx.balanceOf.call(accounts[5]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Account balance : " + accountBalance.toString(10));
        });
        it('ICO Buy - valid in USD', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[6], "USD", new BN("100").mul(deci), {from: accounts[0]});
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let accountBalance = await kmx.balanceOf.call(accounts[6]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Account balance : " + accountBalance.toString(10));
        });
        it('ICO Buy - valid in XAF', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.buyICOTokensForAccount(accounts[7], "XAF", new BN("10000").mul(deci), {from: accounts[0]});
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let accountBalance = await kmx.balanceOf.call(accounts[7]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Account balance : " + accountBalance.toString(10));
        });*/
        const deci = new BN("1000000000000000000", 10);
        it('Contract address balance', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let contractAddressBalance = await kmx.balanceOf.call(KMX_TOKEN_ADDRESS);
            console.log("Contract address balance : " + contractAddressBalance.toString(10));
        })
        /*it('Refund amount EUR', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let eurRfdAmount = await adminCenter.refundICOAmount(accounts[5], "EUR", new BN("452000000000000000000", 10));
            console.log("Refund amount eur : " + (eurRfdAmount.div(deci)).toString(10));
        });
        it('Refund amount USD', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let eurRfdAmount = await adminCenter.refundICOAmount(accounts[6], "USD", new BN("400000000000000000000", 10));
            console.log("Refund amount usd : " + (eurRfdAmount.div(deci)).toString(10));
        });*/
        it('Refund amount XAF', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let eurRfdAmount = await adminCenter.refundICOAmount(accounts[7], "XAF", new BN("68000000000000000000", 10));
            console.log("Refund amount xaf : " + (eurRfdAmount.div(deci)).toString(10));
        });
        /*it('Refund eur', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.refundICO(accounts[5], "EUR", new BN("452000000000000000000", 10));
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let accountBalance = await kmx.balanceOf.call(accounts[5]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Account balance : " + accountBalance.toString(10));
        });
        it('Refund usd', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.refundICO(accounts[6], "USD", new BN("400000000000000000000", 10));
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let accountBalance = await kmx.balanceOf.call(accounts[6]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Account balance : " + accountBalance.toString(10));
        });
        it('Refund xaf', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            await adminCenter.refundICO(accounts[7], "XAF", new BN("68000000000000000000", 10));
        });
        it('Tokens parts', async function(){
            let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let sell = await adminCenter.tokens.call(10);
            let sellRemaining = await adminCenter.tokens.call(11);
            let sellSold = await adminCenter.tokens.call(12);
            let accountBalance = await kmx.balanceOf.call(accounts[7]);
            console.log("Sell : " + sell.toString(10) + "\n" + 
                "Sell remaining " + sellRemaining.toString(10) + "\n" +
                "Sell sold : " + sellSold.toString(10) + "\n" +
                "Account balance : " + accountBalance.toString(10));
        });*/
};

//TO REDO
const testICOBuyWithEther = () => {
    it('Enable buy with ether', async function(){
        let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
        await adminCenter.enableBuyWithEther({from: accounts[0]});
        assert.equal(await adminCenter.isEtherAccepted(), true, "ICO buy with ether must be enabled");
    });
    it('Set oracle url', async function(){
        let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
        await adminCenter.changeTokenEthPriceOracleUrl("https://young-chamber-62260.herokuapp.com/ethpriceinkmx2", {from: accounts[0]});
        assert.equal(await adminCenter._tknEtherPriceOracleUrl(), "https://young-chamber-62260.herokuapp.com/ethpriceinkmx2", "Invalid oracle url");
    });
    it('Start ico', async function(){
        let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
        await adminCenter.startIco({from: accounts[0]});
    });
    it('Buy with ether', async function(){
        let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
        await adminCenter.buyICOTokensWithEther({from: accounts[8], value: Web3.utils.toWei('1', 'ether')});
    });
    it('Tokens parts', async function(){
        let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
        let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
        let sell = await adminCenter.tokens.call(10);
        let sellRemaining = await adminCenter.tokens.call(11);
        let sellSold = await adminCenter.tokens.call(12);
        let accountBalance = await kmx.balanceOf.call(accounts[7]);
        console.log("Sell : " + sell.toString(10) + "\n" + 
            "Sell remaining " + sellRemaining.toString(10) + "\n" +
            "Sell sold : " + sellSold.toString(10) + "\n" +
            "Account balance : " + accountBalance.toString(10));
    });
    /*it('Send ether to contract', async function(){
        let adminCenter = await KMXAdminCenter.at(KMX_ADMIN_CNTR_ADDRESS);
        await adminCenter.sendTransaction({ from: accounts[9], value: new BN("3000000000000000000", "10") });
    });
    it('Contarct balance', async function(){
        var balance = await Web3.eth.getBalance(KMX_ADMIN_CNTR_ADDRESS); //Will give value in.
        //balance = Web3.toDecimal(balance);
        console.log(balance.toString(10));
    });*/
}

const mintBurn = () => {
    it('Is Mint burn allowed', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.changeMintBurnAllowance(false, {from : accounts[0]});
        assert.equal(await kmxStable.isMintBurnAllowed.call(), false, "Mint burn must be disabled");
    });
    it('Mint - not from admin', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.mint(new BN("100000").mul(deci), {from: accounts[1]});
    });
    it('Burn - not from admin', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.burn(new BN("100000").mul(deci), {from: accounts[1]});
    });
    it('Mint - mintburn disabled', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.mint(new BN("100000").mul(deci), {from: accounts[0]});
    });
    it('Burn - mintburn disabled', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.burn(new BN("100000").mul(deci), {from: accounts[0]});
    });
    it('Allow mint burn - not from owner', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.changeMintBurnAllowance(true, {from : accounts[1]});
    });
    it('Allow mint burn - valid', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.changeMintBurnAllowance(true, {from : accounts[0]});
        assert.equal(await kmxStable.isMintBurnAllowed.call(), true, "Mint burn must be enabled");
    });
    it('Mint - valid', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.mint(new BN("100000").mul(deci), {from: accounts[0]});
    });
    it('Token holder balance', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
        console.log("Holder balance : " + tokenHolderBalance.toString(10));
    });
    it('Burn - valid', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        await kmxStable.burn(new BN("100000").mul(deci), {from: accounts[0]});
    });
    it('Token holder balance', async function(){
        let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
        let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
        console.log("Holder balance : " + tokenHolderBalance.toString(10));
    });
}

const testKMXStable = () => {
    /*it('Get Kamix Token discount for fees', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let dff = await kmxStable.getKmxTokenDiscountForFees.call();
            console.log("Discount for fees : " + dff);
        });
        it('Change discount for fees - not from owner', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.changeKmxTokenDiscountForFees(new BN("60000000000000000", "10"), {from: accounts[1]});
        });
        it('Change discount for fees - exceeds fees', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.changeKmxTokenDiscountForFees(new BN("60000000000000000", "10"), {from: accounts[0]});
        });
        it('Change discount for fees', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.changeKmxTokenDiscountForFees(60, {from: accounts[0]});
            let dff = await kmxStable.getKmxTokenDiscountForFees.call();
            console.log("Discount for fees : " + dff);
        });
        it('Set Kamix Token', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.setKmxToken(KMX_TOKEN_ADDRESS);
            let kmxAdd = await kmxStable.getKmxToken.call();
            console.log("KMX Token Address : " + kmxAdd);
        })*/
        /*it('Url and fees', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let url = await kmxStableMarket.stableTokenPriceUrl.call();
            let buykmxfees = await kmxStableMarket.buyKMXFees.call();
            let kmxstable = await kmxStableMarket.kmxStableToken.call();
            console.log("Url : " + url + "\nBuy KMX Fees : " + buykmxfees.toString(10) + "\nKMX Stable : " + kmxstable);
        });*/
        /*it('Set Kamix Token', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.setKmxToken(KMX_TOKEN_ADDRESS);
            let kmxAdd = await kmxStable.getKmxToken.call();
            console.log("KMX Token Address : " + kmxAdd);
        })
        it('Add seller - not by admin', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.addSeller(accounts[8], {from: accounts[1]});
        });
        it('Add seller - valid', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.addSeller(accounts[8], {from: accounts[0]});
            assert.equal(await kmxStableMarket.isSeller.call(accounts[8]), true, "Account 8 must be seller");
        });
        it('Add seller - Already seller', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.addSeller(accounts[8], {from: accounts[0]});
        });
        it('remove seller - not by admin', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.removeSeller(accounts[8], {from: accounts[1]});
        });
        it('remove seller - valid', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.removeSeller(accounts[8], {from: accounts[0]});
            assert.equal(await kmxStableMarket.isSeller.call(accounts[8]), false, "Account 8 must be seller");
        });
        it('remove seller - already removed as seller', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.removeSeller(accounts[8], {from: accounts[0]});
        });
        it('Add seller - valid - acc 8', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.addSeller(accounts[8], {from: accounts[0]});
            assert.equal(await kmxStableMarket.isSeller.call(accounts[8]), true, "Account 8 must be seller");
        });
        it('Add seller - valid - acc 9', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.addSeller(accounts[9], {from: accounts[0]});
            assert.equal(await kmxStableMarket.isSeller.call(accounts[9]), true, "Account 8 must be seller");
        });
        it('Buy tokens - not seller or admin', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buy(accounts[8], "YEN", 0, {from: accounts[1]});
        });
        it('Buy tokens - invalid currency', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buy(accounts[8], "YEN", 0, {from: accounts[9]});
        });
        it('Buy tokens - to token holder', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buy(accounts[0], "EUR", 0, {from: accounts[9]});
        });
        it('Buy tokens - to frozen account', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.frozeAccount(accounts[4], {from: accounts[0]});
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buy(accounts[4], "EUR", 0, {from: accounts[9]});
        });
        it('Buy tokens - amt is 0', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buy(accounts[8], "EUR", 0, {from: accounts[9]});
        });
        it('Buy tokens - caller and account are sellers', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buy(accounts[8], "USD", new BN("100000", 10).mul(deci), {from: accounts[9]});
        });
        it('Buy tokens - valid - for account 8', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let rfd = await kmxStableMarket.buy(accounts[8], "USD", new BN("100000", 10).mul(deci), {from: accounts[0]});
            console.log("Refund : " + rfd.toNumber().div(deci).toString(10));

            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc8Bal = await kmxStable.balanceOf.call(accounts[8]);
            let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
            console.log("Account 8 balance : " + acc8Bal.toString(10) + ", Tkn Holder Balance : " + tokenHolderBalance.toString(10));
        });
        it('Buy tokens - valid - for account 7 by a seller', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let rfd = await kmxStableMarket.buy(accounts[7], "USD", new BN("100000", 10).mul(deci), {from: accounts[9]});
            console.log("Refund : " + rfd.toNumber().div(deci).toString(10));

            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc7Bal = await kmxStable.balanceOf.call(accounts[7]);
            let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
            console.log("Account 7 balance : " + acc7Bal.toString(10) + ", Tkn Holder Balance : " + tokenHolderBalance.toString(10));
        });
        it('Buy tokens - valid - for account 6 by a seller in his account', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let rfd = await kmxStableMarket.buyFromSeller(accounts[6], "USD", new BN("200000", 10).mul(deci), {from: accounts[8]});
            console.log("Refund : " + rfd.toNumber().div(deci).toString(10));

            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc6Bal = await kmxStable.balanceOf.call(accounts[6]);
            let acc8Bal = await kmxStable.balanceOf.call(accounts[8]);
            let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "Account 8 Balance : " + acc8Bal.toString(10) + ", Tkn Holder Balance : " + tokenHolderBalance.toString(10));
        });*/
        /*it('Buy tokens - valid - for account 6 by a seller in his account', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc6Bal = await kmxStable.balanceOf.call(accounts[6]);
            let acc8Bal = await kmxStable.balanceOf.call(accounts[8]);
            let acc7Bal = await kmxStable.balanceOf.call(accounts[7]);
            let acc9Bal = await kmxStable.balanceOf.call(accounts[9]);
            let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + 
            "\nAccount 7 Balance : " + acc7Bal.toString(10) + 
            "\nAccount 8 Balance : " + acc8Bal.toString(10) + 
            "\nAccount 9 Balance : " + acc9Bal.toString(10) + 
            "\nTkn Holder Balance : " + tokenHolderBalance.toString(10));
        });*/
        /*it('Refund amount - exceeds', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let refundAmount = await kmxStableMarket.refundAmount(accounts[6], "USD", new BN("200000", 10).mul(deci), {from: accounts[8]});
        });
        it('Refund amount - valid', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let refundAmount = await kmxStableMarket.refundAmount(accounts[6], "USD", new BN("50000", 10).mul(deci), {from: accounts[8]});
            console.log("Refund amount account 6 - " + refundAmount.toString(10));
        });
        it('Refund from seller', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.refundToSeller(accounts[6], "USD", new BN("50000", 10).mul(deci), {from: accounts[8]});

            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc6Bal = await kmxStable.balanceOf.call(accounts[6]);
            let acc8Bal = await kmxStable.balanceOf.call(accounts[8]);
            let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "Account 8 Balance : " + acc8Bal.toString(10) + ", Tkn Holder Balance : " + tokenHolderBalance.toString(10));
        });
        it('Refund', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.refund(accounts[7], "USD", new BN("50000", 10).mul(deci), {from: accounts[9]});

            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc7Bal = await kmxStable.balanceOf.call(accounts[7]);
            let tokenHolderBalance = await kmxStable.balanceOf.call(accounts[0]);
            console.log("Account 7 balance : " + acc7Bal.toString(10) + ", Tkn Holder Balance : " + tokenHolderBalance.toString(10));
        });*/
        /*it('Set oracle url', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            let url = "https://young-chamber-62260.herokuapp.com/kmx2priceinkmx1";
            await kmxStableMarket.setStableTokenPriceUrl(url, {from: accounts[0]});
            assert.equal(await kmxStableMarket.stableTokenPriceUrl.call(), url, "Url invalid");
        });
        it('Buy tokens', async function(){
            let kmxStableMarket = await KMXStableMarket.at(STABLE_MARKET_ADDRESS);
            await kmxStableMarket.buyKMXTokens(new BN("10000", 10).mul(deci), {from: accounts[6]});
        });*/
        /*it('Show KMX balances', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let acc6Bal = await kmx.balanceOf.call(accounts[6]);
            let acc7Bal = await kmx.balanceOf.call(accounts[7]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "\nAccount 7 balance : " + acc7Bal.toString(10));
        });
        it('Give KMX Tokens to account 6', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.sendKMXToUser(accounts[6], new BN("100000", 10).mul(deci), {from: accounts[0]});
            let acc6Bal = await kmx.balanceOf.call(accounts[6])
            assert.equal(acc6Bal.toString(10), new BN("100000", 10).mul(deci).toString(10), "Account 6 must have 100000");
        });
        it('Give KMX Tokens to account 7', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmx.sendKMXToUser(accounts[7], new BN("100000", 10).mul(deci), {from: accounts[0]});
            let acc7Bal = await kmx.balanceOf.call(accounts[7])
            assert.equal(acc7Bal.toString(10), new BN("100000", 10).mul(deci).toString(10), "Account 6 must have 100000");
        });
        it('Show KMX balances', async function(){
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let acc6Bal = await kmx.balanceOf.call(accounts[6]);
            let acc7Bal = await kmx.balanceOf.call(accounts[7]);
            let tokenHolderBalance = await kmx.balanceOf.call(accounts[0]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "\nAccount 7 balance : " + acc7Bal.toString(10) + "\nToken holder balance : " + tokenHolderBalance.toString(10));
        });*/
        /*it('Froze account 4', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let isFrozen = await kmxStable.isAccountFrozen.call(accounts[4]);
            if (!isFrozen){
                await kmxStable.frozeAccount(accounts[4], {from: accounts[0]});
            }
            assert.equal(await kmxStable.isAccountFrozen.call(accounts[4]), true, "Account 4 must be frozen");
        });
        it('Transfer - sender frozen', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transfer(accounts[7], 0, {from: accounts[4]});
        });
        it('Transfer - receiver frozen', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transfer(accounts[4], 0, {from: accounts[6]});
        });
        it('Transfer - sender token holder', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transfer(accounts[7], 0, {from: accounts[0]});
        });
        it('Transfer - amount 0', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transfer(accounts[7], 0, {from: accounts[6]});
        });
        it('Transfer - amount exceed', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transfer(accounts[7], new BN("100000", 10).mul(deci), {from: accounts[6]});
        });
        it('Transfer - valid', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transfer(accounts[7], new BN("10000", 10).mul(deci), {from: accounts[6]});
            let acc6Bal = await kmx.balanceOf.call(accounts[6]);
            let acc7Bal = await kmx.balanceOf.call(accounts[7]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "\nAccount 7 balance : " + acc7Bal.toString(10));
        });
        it('Allowance', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.approve(accounts[5], new BN("20000", 10).mul(deci), {from: accounts[7]});
            let approved = await kmxStable.allowance(accounts[7], accounts[5]);
            console.log("Account 7 approved to account 5 : " + approved.toString(10));
        });
        it('Transfer from - no allowance', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transferFrom(accounts[6], accounts[7], new BN("10000", 10).mul(deci), {from: accounts[9]});
        });
        it('Transfer from - valid', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.transferFrom(accounts[6], accounts[7], new BN("10000", 10).mul(deci), {from: accounts[5]});
            let acc6Bal = await kmx.balanceOf.call(accounts[6]);
            let acc7Bal = await kmx.balanceOf.call(accounts[7]);
            let approved = await kmxStable.allowance(accounts[7], accounts[5]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "\nAccount 7 balance : " + acc7Bal.toString(10) + "\nAccount 7 approved to account 5 : " + approved.toString(10));
        });*/
        it('Transfer from - valid', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let acc6Bal = await kmxStable.balanceOf.call(accounts[6]);
            let acc7Bal = await kmxStable.balanceOf.call(accounts[7]);
            let approved = await kmxStable.allowance(accounts[7], accounts[5]);
            console.log("Account 6 balance : " + acc6Bal.toString(10) + "\nAccount 7 balance : " + acc7Bal.toString(10) + "\nAccount 7 approved to account 5 : " + approved.toString(10));
        });
}

const testStableTFWithKMXFees = () => {
    /*it('Approve', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            await kmxStable.approve(accounts[5], new BN("20000", 10).mul(deci), {from: accounts[7]});
            await kmx.approve(accounts[5], new BN("10000", 10).mul(deci), {from: accounts[7]});
            let s5app = await kmxStable.allowance.call(accounts[7], accounts[5]);
            let v5app = await kmx.allowance.call(accounts[7], accounts[5]);
            console.log("Allowance acc 5 in KMX1 : " + s5app.toString(10) + ", Allowance acc 5 in KMX2 : " + v5app.toString(10));
        });
        it('Balances', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let s6bal = await kmxStable.balanceOf.call(accounts[6]);
            let s7bal = await kmxStable.balanceOf.call(accounts[7]);
            let v6bal = await kmx.balanceOf.call(accounts[6]);
            let v7bal = await kmx.balanceOf.call(accounts[7]);
            let s5app = await kmxStable.allowance.call(accounts[7], accounts[5]);
            let v5app = await kmx.allowance.call(accounts[7], accounts[5]);
            console.log("Balances account 6 : " + s6bal.div(deci) + " KMX1, " + v6bal.div(deci) + " KMX2\n"
             + "Balances account 7 : " + s7bal.div(deci) + " KMX1, " + v7bal.div(deci) + " KMX2\n"
             + "Allowance acc 5 in KMX1 : " + s5app.div(deci) + " KMX1; Allowance acc 5 in KMX2 : " + v5app.div(deci) + " KMX2");
        });
        it('Transfer fees in KMX', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            await kmxStable.kmxStableTokenTransferFromKMXFees(accounts[7], accounts[6], new BN("10000", 10).mul(deci), stbTknPrice, {from: accounts[5]});
        });
        it('Balances', async function(){
            let kmxStable = await KMXStable.at(STABLE_TOKEN_ADDRESS);
            let kmx = await KMX.at(KMX_TOKEN_ADDRESS);
            let s6bal = await kmxStable.balanceOf.call(accounts[6]);
            let s7bal = await kmxStable.balanceOf.call(accounts[7]);
            let v6bal = await kmx.balanceOf.call(accounts[6]);
            let v7bal = await kmx.balanceOf.call(accounts[7]);
            let s5app = await kmxStable.allowance.call(accounts[7], accounts[5]);
            let v5app = await kmx.allowance.call(accounts[7], accounts[5]);
            console.log("Balances account 6 : " + s6bal.div(deci) + " KMX1, " + v6bal.div(deci) + " KMX2\n"
             + "Balances account 7 : " + s7bal.div(deci) + " KMX1, " + v7bal.div(deci) + " KMX2\n"
             + "Allowance acc 5 in KMX1 : " + s5app.div(deci) + " KMX1; Allowance acc 5 in KMX2 : " + v5app.div(deci) + " KMX2");
        });*/ 
}