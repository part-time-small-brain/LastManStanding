import { ethers } from "ethers";
import create from "zustand";
import { devtools } from "zustand/middleware";

// interface Web3State {
//   isInstalledWallet: boolean;
//   isConnected: boolean;
//   connectedAccount: string | null;
//   setIsConnected: (pay: boolean) => void;
//   setIsInstalledWallet: (pay: boolean) => void;
//   setConnectedAccount: (pay: string | null) => void;
//   //////////////////////////////////////////////////
//   contract: ethers.Contract | null;
//   balance: string | number;
//   setContract: (pay: ethers.Contract) => void;
//   setBalance: (pay: number | string) => void;
// }

const useWeb3Store = create(
  devtools((set) => ({
    isInstalledWallet: false,
    isConnected: false,
    connectedAccount: null,
    setIsConnected: (pay) => set((state) => ({ isConnected: pay })),
    setIsInstalledWallet: (pay) => set((state) => ({ isInstalledWallet: pay })),
    setConnectedAccount: (pay) => set((state) => ({ connectedAccount: pay })),
    //////////////////////
    contract: null,
    tokenContract: null,
    balance: 0,
    blockTimestamp: 0,
    setBlockTimestamp: (pay) => set((state) => ({ blockTimestamp: pay })),
    setContract: (pay) => set((state) => ({contract: pay})),
    setTokenContract: (pay) => set((state) => ({tokenContract: pay})),
    setBalance: (pay) => set(state => ({balance: pay}))
  }))
);

export default useWeb3Store;
