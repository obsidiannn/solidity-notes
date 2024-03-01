const Payable = artifacts.require("RmcErc20"); 

module.exports = function (deployer) {

	const name = "RaymooonnToken";
	const symbol = "RMT";
	const amount = 1000;
	console.log("Deploying RmcErc20 with parameters:", name, symbol, amount);

	deployer.deploy(Payable,name,symbol,amount);
	

	
};