import * as React from 'react';
import { Box, Typography, TextField, Button } from '@mui/material'
import { ConnectWalletButton } from './'

export default function Branding() {
  return (
    <Box sx={{p: 5, ml: 3, flexGrow: 1, height: "100%"}}>
        <Box sx={{ 
            // border: "1px solid white",
            height: "100%",
            width: 350, 
            borderRadius: 5,
            p: 4,
            position: "relative",
            display: "flex", 
            flexDirection: "column", 
            justifyContent: "center",
            background: "#00000000 box, linear-gradient(to right top, #3687ff, #5579fa, #6f69f2, #8655e7, #9b3cd8) border-box",
            backgroundClip: "padding-box",
            boxSizing: "border-box",
            borderWidth: 2,
            borderColor: "transparent",borderStyle: "solid",
            bgcolor: "#000000",
            position: "relative",
            "&:before": {
                content: "''",
                position: "absolute",
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                zIndex: -1,
                margin: '-5px',
                borderRadius: "inherit",
                background: "linear-gradient(to right top, #3687ff, #5579fa, #6f69f2, #8655e7, #9b3cd8)"
            }

        }}>
            <Box component="span" sx={{display: "flex", alignItems: "flex-end", mb: 1}}>
                <Typography variant="h5" sx={{lineHeight: 0.7}}>Be the</Typography>
            </Box>
            <Typography variant="h1" sx={{lineHeight: 1, fontSize: 40, fontWeight: "900"}}>LAST MAN</Typography>
            <Typography variant="h1" sx={{lineHeight: 1, fontSize: 50, fontWeight: "900", mb: 2}}>STANDING</Typography>
            <ConnectWalletButton width={"70%"}/>
        </Box>
    </Box>
  );
}