import { useContractRead } from "wagmi";
import { createContract } from "./contract";
import { Buffer } from "buffer";
import BN from "bn.js";
import { createHash } from "crypto";

export const getNotesLength = async () => {
  const c = createContract();
  const len = await c.getNotesLength();
  return len;
};

export const getNotes = async (account) => {
  const contract = createContract();
  const notes = [];
  const userAccount = account.slice(2);
  console.log(userAccount);

  const len = await contract.getNotesLength();
  for (let i = 0; i < len; i++) {
    const cipher = await contract.allNotes(i);
    console.log("cipher", cipher);
    const dec = await decrypt(cipher, userAccount);
    console.log("dec", dec);
    if (dec.match) {
      console.log("worked");
      const noteHash = getNoteHash(userAccount, dec.amount);
      const state = await contract.notes("0x" + noteHash);
      if (state === 1 || state === 2) {
        notes.push({
          hash: "0x" + noteHash,
          status: state === 1 ? "Created" : "Spent",
          amount: parseInt(dec.amount, 16),
        });
      }
    }
  }
  return notes;
};

export const getAllNotes = async () => {
  const contract = createContract();
  const notes = [];
  const len = await contract.getNotesLength();
  for (let i = 0; i < len; i++) {
    const hash = await contract.allNotes(i);
    const hash2 = await contract.allHashedNotes(i);
    console.log(hash2);
    notes.push({ hash });
  }
  return notes;
};

// export const claimDAI = async (amount) => {
//   const accounts = await getAccounts();
//   console.log("accounts", accounts, amount);
//   await SecretNote.methods.claimNote(amount).send({
//     from: accounts[0],
//     gasPrice: "0x" + parseInt("10000000000").toString(16),
//   });
// };

export function getNoteHash(address, amount) {
  let _address = address + "000000000000000000000000";
  let _amount = new BN(amount, 16).toString(16, 64); // 32 bytes = 64 chars in hex
  console.log(_address, _amount);
  const buf = Buffer.from(_address + _amount, "hex");
  const digest = createHash("sha256").update(buf).digest("hex");
  console.log("digest", digest);
  return digest;
}

export async function decrypt(cipher, userAccount) {
  const address = cipher.slice(0, 40).toLowerCase();
  const amount = cipher.slice(40);
  console.log(address, amount);
  return { match: address === userAccount.toLowerCase(), amount };
}
