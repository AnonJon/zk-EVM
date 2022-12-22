import Head from "next/head";
import styles from "./layout.module.css";
import NavBar from "./navbar";
// import Footer from "./footer";
import { useState, useEffect } from "react";
import {
  Box,
  Center,
  Container,
  Flex,
  IconButton,
  Spacer,
} from "@chakra-ui/react";
import { ArrowDownIcon, ArrowUpIcon } from "@chakra-ui/icons";
export const siteTitle = "ChainAccess";

export const Layout = ({
  children,
  canToggleHeader = false,
  title = "ChainAccess",
}) => {
  const [width, setWidth] = useState(800);
  const [toggleHeader, setToggleHeader] = useState(true);

  if (typeof window !== "undefined") {
    useEffect(() => {
      setWidth(window.innerWidth);
    }, []);
  }
  return (
    <div className={styles.container}>
      <NavBar width={width} />
      <Head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <div className={styles.mainArea}>{children}</div>
      {/* <Container maxWidth="1200px">
        <Flex
          py={4}
          justifyContent="flex-end"
          alignItems="center"
          height={toggleHeader ? undefined : "30px"}
        >
          <Spacer />
          <IconButton
            size="sm"
            variant="ghost"
            icon={toggleHeader ? <ArrowUpIcon /> : <ArrowDownIcon />}
            hidden={!canToggleHeader}
            aria-label="toggle header"
            onClick={() => setToggleHeader(!toggleHeader)}
          />
          <Spacer />
          <Center hidden={!toggleHeader} />
        </Flex>
        {children}
      </Container> */}
    </div>
  );
};
