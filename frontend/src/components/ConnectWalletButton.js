import Button from '@mui/material/Button'
import useWeb3Store from '../utils/web3store';

export default function Connect({ setAccount, onConnect, width }) {
    const isConnected = useWeb3Store((state) => state.isConnected);
    const isInstalledWallet = useWeb3Store((state) => state.isInstalledWallet);
    const setConnectedAccount = useWeb3Store(
        (state) => state.setConnectedAccount
    );
    const connectWallet = async () => {
        try {
            if (!isInstalledWallet) {
                return false;
            }
            const accounts = await (window.ethereum).request({
                method: "eth_requestAccounts",
            });
            if (accounts && accounts.length) {
                setConnectedAccount(accounts[0]);
            }
        } catch (error) {
            console.log(error);
            throw new Error("No ethereum object.");
        }
    };
    return (
        <Button
            variant="contained"
            size="large"
            sx={{
                background: "linear-gradient(to right, #30A9CF 2.13%, rgba(186, 38, 238, 0.95) 100%)",
                color: "black", borderRadius: 5, fontWeight: "900", width: width || "100%"
            }}
            disabled={isConnected}
            onClick={connectWallet}>
            {isConnected ? "Connected" : "Connect Wallet"}
        </Button>
    )
}
