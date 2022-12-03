import * as React from 'react';
import { Box, Typography, Button } from '@mui/material'
import { boldFont } from '../theme';
import AccessTimeIcon from '@mui/icons-material/AccessTime';

export default function Jackpot() {
  return (
    <Box sx={{
        width: "100%",
        // textAlign: "center",
        p: 5,
    }}>
        <Box sx={{
            display: "flex",
            alignItems: "center"
        }}>
            <Box sx={{mt: -3}}>
                <Typography variant="h1" sx={{fontWeight: "900", fontFamily: 'Helvetica, serif', fontSize: 250}}>
                    <i>$</i>
                    {/* $ */}
                </Typography>
            </Box>
            <Box sx={{ml: 2}}>
                <Typography variant="h4" sx={{textTransform: "uppercase", fontFamily: boldFont.style.fontFamily, ml: 3}}>
                    Jackpot Amount
                </Typography>
                <Typography variant="h1" sx={{fontWeight: "900", fontSize: 180, fontFamily: "Helvetica", lineHeight: 0.8}}>
                    1509.32
                </Typography>
                <Typography variant="h4" sx={{fontWeight: "900", ml: 3, mt: 1}}>in <AccessTimeIcon/> 10:20:25 to 
                    <Box component="span" sx={{color: "primary.main"}}> 0xe73C12d2...c4C</Box>
                </Typography>            
            </Box>
        </Box>
        
    </Box>
  );
}