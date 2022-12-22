import { ethers } from "ethers";
import noteABI from "./noteABI.json";

const CONTRACT_ADDRESS = "0x9e5dBfF85B525e82C40B8D8D41fcA1ae27ACAc6E";

export const createContract = () => {
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.NEXT_PUBLIC_GOERLI_RPC,
    5
  );
  const noteContract = new ethers.Contract(CONTRACT_ADDRESS, noteABI, provider);
  return noteContract;
};
