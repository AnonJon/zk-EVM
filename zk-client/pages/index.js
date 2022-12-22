import Head from "next/head";
import { useEffect, useState } from "react";
import Image from "next/image";
import styles from "../styles/Home.module.css";
import { useAccount } from "wagmi";
import {
  Table,
  Thead,
  Tbody,
  Tfoot,
  Tr,
  Th,
  Td,
  TableCaption,
  TableContainer,
} from "@chakra-ui/react";
import { getNotesLength, getAllNotes, getNotes } from "../contracts/utils";
import { useIsMounted } from "../hooks/app-hooks";
import { Layout } from "../components/layout";

export default function Home() {
  const [len, setLength] = useState("");
  const [note, setNotes] = useState("");
  const { address, connector, isConnected } = useAccount();

  return (
    <Layout>
      <h1>Home</h1>
    </Layout>
  );
}
