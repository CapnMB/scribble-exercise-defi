/**
* @type import('hardhat/config').HardhatUserConfig
*/
require("@nomiclabs/hardhat-ethers");

module.exports = {
solidity: {
compilers: [
{
version: "0.4.21",
settings: {},
},
{
version: "0.6.0",
settings: {},
},
{
version: "0.6.12",
settings: {},
},
{
version: "0.8.0",
settings: {},
},
{
version: "0.8.1",
settings: {},
},

// add more compiler versions here if needed
],
},

};

