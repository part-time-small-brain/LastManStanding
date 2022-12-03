import { Box, Grid } from '@mui/material';
import { NoMetamask } from '../src/components';
import { useEffect, useState } from 'react';
import { Topbar, Jackpot, Staker, Rewards, Branding } from '../src/components/';
import useWeb3Store from '../src/utils/web3store';

export default function Index() {
  const isInstalledWallet = useWeb3Store(state => state.isInstalledWallet)
  return (
    <Box>
      {!isInstalledWallet && <NoMetamask />}
      <Box sx={{
      height: "100vh",
      width: "100%",
      pl: 10,
      overflow: "hidden",
      position: "relative"
    }}>
      <Box component="img" src="/smudge.svg" sx={{position: "absolute", zIndex: -1, top: "-30%", right: "-20%"}}/>
      <Box component="img" src="/smudge2.svg" sx={{position: "absolute", zIndex: -1, bottom: "-20%", left: "-20%", height: "70%"}}/>
      <Topbar />
      <Jackpot />
      <Grid container sx={{height: "30%"}} spacing={0} justifyContent="flex-start">
        <Grid item md={3.3} sm={12} xs={12}>
          <Branding />
        </Grid>
        <Grid item md={3.3} sm={12} xs={12}>
          <Staker />
        </Grid>
        <Grid item md={3.3} sm={12} xs={12}>
          <Rewards />
        </Grid>
      </Grid>
    </Box>
    </Box>
  );
}