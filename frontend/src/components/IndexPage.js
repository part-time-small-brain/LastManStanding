import * as React from 'react';
import { Box, Grid } from '@mui/material';
import { Topbar, Jackpot, Staker, Rewards, Branding } from './';

export default function Index() {
  return (
    <Box sx={{
      // background: "linear-gradient(to right top, #00f6ff, #71f6ff, #a6f6ff, #cdf6ff, #ecf7ff, #edf8ff, #edf8ff, #eef9ff, #d1f9ff, #affaff, #88fbff, #5ffbf1)",
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
  );
}