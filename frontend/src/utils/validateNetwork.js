export const validateNetwork = (ethereum, chainId) => {
    if (ethereum.networkVersion !== chainId) {
        ethereum.request({
            method: "wallet_addEthereumChain",
            params: [{
                chainId:  "0x13881", // make this dynamic
                rpcUrls: ["https://rpc.ankr.com/polygon_mumbai"],
                chainName: "Matic(Polygon) Mumbai Testnet",
                nativeCurrency: {
                    name: "MATIC",
                    symbol: "MATIC",
                    decimals: 18
                },
                blockExplorerUrls: ["https://polygonscan.com/"]
            }]
        });
    }
}