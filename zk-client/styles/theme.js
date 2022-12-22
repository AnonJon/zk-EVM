import {
  extendTheme,
  textDecoration,
  withDefaultColorScheme,
} from "@chakra-ui/react";

const config = {
  initialColorMode: "light",
  useSystemColorMode: false,
};

const theme = extendTheme({
  config,
  brand: {
    50: "black.50",
    100: "black.100",
    500: "gray.500", // you need this
  },
  components: {
    Link: {
      baseStyle: {
        textDecoration: "none",
      },
    },
    Button: {
      baseStyle: {
        // ...define your base styles
        backgroundColor: "rgb(123,63,228)",
        color: "white",
      },
      variants: {
        // Make a variant, we'll call it `base` here and leave it empty
        action: {
          backgroundColor: "rgb(123,63,228)",
          color: "white",
        },
        ghost: {
          backgroundColor: "rgb(167,136,222)",
          color: "black",
        },
        wallet: {
          // backgroundColor: "rgb(167,136,222)",
          backgroundColor: "white",
          color: "black",
        },
      },
    },
  },
  styles: {
    global: (props) => ({
      "html, body": {
        fontSize: "16px",
        color: "black",
        lineHeight: "tall",
        fontFamily: `"system-ui","-apple-system","BlinkMacSystemFont","Segoe UI","Helvetica","Arial","sans-serif"`,
        height: "100%",
      },
      "div#__next": {
        height: "100%",
      },
      a: {
        color: "black",
      },
      body: {
        bg: "",
      },
    }),
  },
});

export default theme;
