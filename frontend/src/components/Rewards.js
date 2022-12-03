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
            p: 4,
            position: "relative",
            display: "flex", 
            flexDirection: "column", 
            justifyContent: "center"
        }}>
            <Box component="span" sx={{display: "flex", alignItems: "flex-end", mb: 1}}>
                <Typography variant="h2" sx={{lineHeight: 0.7, fontSize: 50}}>12%</Typography>
                <Typography variant="h6" sx={{ml: 2}}>APY</Typography>
            </Box>
            <Box component="span" sx={{display: "flex", alignItems: "flex-end", mt: 2}}>
                <Typography variant="h2" sx={{lineHeight: 0.7, fontSize: 100}}>1024</Typography>
                <Typography variant="h4" sx={{ml: 2}}>LMS</Typography>
            </Box>
            <Box sx={{display: "flex", alignItems: "flex-end", mt: 2}}>
                <Button
                    variant="contained"
                    size="large"
                    sx={{
                        bgcolor: "white", 
                        color: "black", 
                        borderRadius: 5, 
                        py: 0.5, 
                        fontWeight: "900"}}>
                    Claim 
                </Button>
                <Button
                    variant="contained"
                    size="large"
                    sx={{
                        bgcolor: "white", 
                        color: "black", 
                        borderRadius: 5, 
                        ml: 2,
                        py: 0.5, 
                        fontWeight: "900"}}>
                    Compound
                </Button>
            </Box>
        </Box>
    </Box>
  );
}