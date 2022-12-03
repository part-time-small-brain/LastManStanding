import { createTheme } from '@mui/material/styles';
import { red } from '@mui/material/colors';
import localFont from '@next/font/local'

// Font files can be colocated inside of `pages`
const SFNewRepublic = localFont({ src: '../fonts/sf_new_republic/SF New Republic.ttf' })
const SFNewRepublicBold = localFont({ src: '../fonts/sf_new_republic/SF New Republic Bold.ttf' })

// Create a theme instance.
const theme = createTheme({
  palette: {
    primary: {
      main: '#00f6ff',
    },
    secondary: {
      main: '#fff',
    },
    error: {
      main: red.A400,
    },
    background: {
        default: "#040404"
    },
    text: {
      primary: "#fff"
    }
  },
  typography: {
    fontFamily: SFNewRepublic.style.fontFamily + ',' + SFNewRepublicBold.style.fontFamily,
    lineHeight: 1
  },
  components: {
    MuiCssBaseline: {
      styleOverrides: SFNewRepublic.className,
    },
  },
});


export default theme;
export {
  SFNewRepublic as font,
  SFNewRepublicBold as boldFont
}