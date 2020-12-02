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

module.exports = {
    accounts: {
        test: {
            ZERO: { pub: account0, priv: privateKey0},
            FIRST: { pub: account1, priv: privateKey1},
            SECOND: { pub: account2, priv: privateKey2},
            THIRD: { pub: account3, priv: privateKey3},
            FOURTH: { pub: account4, priv: privateKey4},
            FIFTH: { pub: account5, priv: privateKey5},
            SIXTH: { pub: account6, priv: privateKey6},
            SEVENTH: { pub: account7, priv: privateKey7},
            EIGHTH: { pub: account8, priv: privateKey8},
            NINTH: { pub: account9, priv: privateKey9},
        },
        main: {
            MAIN: {pub: "", priv: ""},
            SECOND: {pub: "", priv: ""}
        }
    },
    providers: {
        LOCAL: "http://127.0.0.1:7545",
        ROPSTEN: "https://ropsten.infura.io/v3/a375cbadab474382be7264c909333b6e",
        MAINNET: ""
    }
}