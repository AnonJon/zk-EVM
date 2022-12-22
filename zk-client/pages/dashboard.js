// import Head from "next/head";
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

export default function Dashboard() {
  const [len, setLength] = useState("");
  const [amounts, setAmounts] = useState([]);
  const [domLoaded, setDomLoaded] = useState(false);
  const { address, connector, isConnected } = useAccount();
  const isMounted = useIsMounted();

  const allNotes = async () => {
    const len = await getAllNotes();
    console.log(len);
  };
  const getallNotes = async (address) => {
    const n = await getNotes(address);
    return n;
  };

  useEffect(() => {
    if (address) {
      (async () => {
        const c = await getallNotes(address);
        setAmounts(c);
      })();
      return () => {};
    }
  }, [address]);

  useEffect(() => {
    setDomLoaded(true);
  }, []);

  return (
    <>
      {domLoaded && (
        <Layout>
          {/* {isConnected ? <p>Amount: {amount}</p> : <></>} */}
          <TableContainer>
            <Table variant="simple">
              <TableCaption>Transactions</TableCaption>
              <Thead>
                <Tr>
                  <Th>Hash</Th>
                  <Th>Status</Th>
                  <Th isNumeric>Amount</Th>
                </Tr>
              </Thead>
              {amounts.map((amount) => {
                return (
                  <Tbody key={amount.hash}>
                    <Tr>
                      <Th>{amount.hash}</Th>
                      <Th>{amount.status}</Th>
                      <Th isNumeric>{amount.amount}</Th>
                    </Tr>
                  </Tbody>
                );
              })}
              <Tfoot>
                <Tr>
                  <Th></Th>
                  <Th></Th>
                  <Th isNumeric></Th>
                </Tr>
              </Tfoot>
            </Table>
          </TableContainer>
        </Layout>
      )}
    </>
  );
}
