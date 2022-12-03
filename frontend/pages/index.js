import * as React from 'react';
import { Box, Grid } from '@mui/material';
import IndexPage from '../src/components/IndexPage';
import { NoMetamask } from '../src/components';


export default function Index() {

  const [ metamask, setMetamask ] = React.useState(false);

  React.useEffect(() => {
    if (window.ethereum) setMetamask(true);
  }, [])
  return (
    <Box>
      {!metamask && <NoMetamask />}
      <IndexPage />
    </Box>
  );
}