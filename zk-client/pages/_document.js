import { ColorModeScript } from "@chakra-ui/react";
import { Global } from "@emotion/react";
import NextDocument, { Head, Html, Main, NextScript } from "next/document";
import fonts from "../styles/font-face";
import theme from "../styles/theme";

export default class Document extends NextDocument {
  static getInitialProps(ctx) {
    return NextDocument.getInitialProps(ctx);
  }

  // eslint-disable-next-line class-methods-use-this
  render() {
    return (
      <Html lang="en">
        <Head>
          <Global styles={fonts} />
          <link rel="alternate icon" href="/favicon.ico" />
          <link rel="icon" type="image/svg+xml" href="/img/atxdao.svg" />
        </Head>
        <body>
          <ColorModeScript initialColorMode={theme.config.initialColorMode} />
          <Main />
          <NextScript />
        </body>
      </Html>
    );
  }
}
