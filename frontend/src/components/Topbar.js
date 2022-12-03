import * as React from 'react';
import { Box, AppBar, Toolbar, Typography, Button } from '@mui/material'
import { ConnectWalletButton } from './index'

export default function Index() {
  return (
    <Box sx={{ flexGrow: 1 }}>
        <AppBar position="static" color="transparent" elevation={0}>
            <Toolbar>
            <Typography variant="h6" component="div" sx={{ flexGrow: 1, fontWeight: "900" }}>
            </Typography>
            {/* <ConnectWalletButton /> */}
            </Toolbar>
        </AppBar>
    </Box>
  );
}