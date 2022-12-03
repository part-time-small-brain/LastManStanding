import { Box, Button, Typography } from '@mui/material'
export default function NoMetamask() {
  return (
    <Box sx={{height: '100%', width: '100%', position: 'absolute', zIndex: 1, bgcolor: 'rgba(0, 0, 0, 0.8)', backdropFilter: 'blur(3px)', display: 'flex', justifyContent: 'center', flexDirection: 'column', p: {md: 30, xs: 5}}}>
      <Typography variant="h2" sx={{color: 'white', width: '100%', textAlign: 'left'}}><b>Make sure you have metamask installed!</b></Typography>
      <Button
        variant="contained"
        size="large"
        sx={{bgcolor: "white", color: "black", mt: 3, borderRadius: 5, maxWidth: 280, fontWeight: '900', textTransform: 'capitalize', fontSize: {md: 20, xs: 15}}}
        href="https://metamask.io/download/">
        Download Metamask
      </Button>
    </Box>
  );
}