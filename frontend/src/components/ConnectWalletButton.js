import React from 'react'
import Button from '@mui/material/Button'
import { ethers } from 'ethers'
import { validateNetwork } from '../utils.js/validateNetwork'
export default function Connect({ setAccount, onConnect, width}) {

    const connectWallet = async () => {
        try {
            const { ethereum } = window;
            if (!ethereum) {
            // setMetamask(false);
            return;
            }
            const accounts = await ethereum.request({ method: "eth_requestAccounts" });
            validateNetwork(ethereum, '80001');
            
            console.log("Connected", accounts[0], network);
            // setAccount(accounts[0]);
            onConnect();
        } catch (error) {
            console.log(error)
        }
    }

    React.useEffect(() => {
        if (window.ethereum) {
            validateNetwork(window.ethereum, '80001')
        }
    }, [])


    return (
        <Button
            variant="contained"
            size="large"
            sx={{background: "linear-gradient(to right, #30A9CF 2.13%, rgba(186, 38, 238, 0.95) 100%)", 
            color: "black", borderRadius: 5, fontWeight: "900", width: width || "100%"}}
            onClick={connectWallet}>
            Connect Wallet
        </Button>
    )
}
