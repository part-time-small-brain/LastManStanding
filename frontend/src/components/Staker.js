import * as React from 'react';
import { Box, Typography, TextField, Button } from '@mui/material'
import AccessTimeIcon from '@mui/icons-material/AccessTime';


function Timer() {
    return (
        <Box sx={{
            position: "absolute",
            right: 10,
            top: 10
        }}>
            <AccessTimeIcon sx={{fontSize: 50}}/>
        </Box>
    )
}
export default function Stacker() {
  return (
    <Box sx={{p: 5, ml: 3, flexGrow: 1, height: "100%"}}>
        <Box sx={{ 
            border: "1px solid white",
            height: "100%",
            width: 350, 
            borderRadius: 5,
            p: 2,
            position: "relative"
        }}>

            <Box sx={{
                position: "relative",
                p: 2,
            }}>
                <Timer/>
                <Typography variant="h2" sx={{lineHeight: 0.8}}>$00.00</Typography>
                <Typography variant="body1">Amount Invested</Typography>
                <Box sx={{position: "relative", pt: 5, mt: 2}}>
                    <TextField 
                        id="filled-basic" 
                        variant="standard"
                        color="secondary"
                        focused
                        sx={{
                            width: "100%",
                            fontSize: 70,
                    }}/>
                    <Button
                        variant="contained"
                        size="large"
                        sx={{
                            bgcolor: "white", 
                            color: "black", 
                            borderRadius: 5, 
                            position: "absolute",
                            right: 0,
                            py: 0.5, 
                            bottom: 10,
                            fontWeight: "900"}}>
                        Stake
                    </Button>
                </Box>
                <Box sx={{position: "relative", pt: 5}}>
                    <TextField 
                        id="filled-basic" 
                        variant="standard"
                        color="secondary"
                        focused
                        sx={{
                            width: "100%",
                            fontSize: 70,
                    }}/>
                    <Button
                        variant="contained"
                        size="large"
                        sx={{
                            bgcolor: "white", 
                            color: "black", 
                            borderRadius: 5, 
                            position: "absolute",
                            right: 0,
                            py: 0.5, 
                            bottom: 10,
                            fontWeight: "900"}}>
                        Unstake
                    </Button>
                </Box>


                
            </Box>
        </Box>
    </Box>
  );
}