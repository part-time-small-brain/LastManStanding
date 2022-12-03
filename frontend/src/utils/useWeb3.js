/* eslint-disable react-hooks/exhaustive-deps */
import { useState, useEffect, useCallback } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS as contractAddress, TOKEN_CONTRACT_ADDRESS } from "../constants";
import abi from "../staking-abi.json";
import abi2 from "../token-abi.json";
import useWeb3Store from "./web3store";
import shallow from "zustand/shallow"


const useWeb3 = () => {
  const connectedAccount = useWeb3Store((state) => state.connectedAccount);
  const [setBalance] = useWeb3Store(state => [state.setBalance], shallow)
  const [provider, setProvider] = useState(null);
  const [setContract, setTokenContract, isInstalledWallet, setBlockTimestamp] = useWeb3Store(state => [state.setContract, state.setTokenContract, state.isInstalledWallet, state.setBlockTimestamp], shallow)

  const BalanceContract = useCallback(async () => {
    const balance = await provider.getBalance(connectedAccount);
    setBalance(ethers.utils.formatEther(balance));
    const Contract = new ethers.Contract(
      contractAddress,
      abi,
      provider.getSigner()
    );
    const TokenContract = new ethers.Contract(
      TOKEN_CONTRACT_ADDRESS,
      abi2,
      provider.getSigner()
    );
    setContract(Contract);
    setTokenContract(TokenContract);
  }, [connectedAccount, provider]);

  useEffect(() => {
    if (!isInstalledWallet) return;
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    setProvider(provider);
    provider.on("block", async (blockNumber) => {
      const block = await provider.getBlock(blockNumber);
      setBlockTimestamp(block.timestamp);
    })
  }, [isInstalledWallet]);

  useEffect(() => {
    if (connectedAccount && provider) BalanceContract();
  }, [connectedAccount, provider, BalanceContract]);
};

export default useWeb3;
