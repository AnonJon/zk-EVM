const { initialize } = require("zokrates-js");
const fs = require("fs/promises");
const { ethers } = require("ethers");
const abi = require("../contracts/abi/verifier.json");
const { getTransferZkParams } = require("./cmd");
require("dotenv").config();

const VERIFICATION = "verification";
const PROVING = "proving";
const VERIFY_CONTRACT = "0xDa1Bd7976De6A458B89A615d8197A22D7e6cb08D";

async function getKey(type) {
  console.log(`Get ${type} Key called`);
  const data = await fs.readFile(`circuits/${type}.key`);
  const buffer = new Uint8Array(data);
  return buffer;
}

async function main() {
  try {
    console.log(process.env.RINKEBY_RPC);
    const provider = new ethers.providers.JsonRpcProvider(
      process.env.RINKEBY_RPC,
      4
    );
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const verifierContract = new ethers.Contract(
      VERIFY_CONTRACT,
      abi,
      provider
    );
    const contractWithSigner = verifierContract.connect(signer);

    const zokratesProvider = await initialize();
    const source = `import "hashes/sha256/512bitPacked" as sha256packed; def main(field onh0, field onh1, private field ona, private field onb, private field onc, private field ond, field nn1h0, field nn1h1, private field nn1a, private field nn1b, private field nn1c, private field nn1d, field nn2h0, field nn2h1, private field nn2c, private field nn2d) -> field {
    // get public key corresponding to private key
    // too complex right now so sending in the public key instead
    field pka = ona;
    field pkb = onb;

    // old note
    field[2] mut h = sha256packed([pka, pkb, onc, ond]);
    assert(h[0] == onh0); // verify with public input (hash of the note)
    assert(h[1] == onh1);

    // new note 1 that goes to pkreciever
    h = sha256packed([nn1a, nn1b, nn1c, nn1d]);
    assert(h[0] == nn1h0);
    assert(h[1] == nn1h1);

    // new note (left over change) that goes back to sender (pk)
    h = sha256packed([pka, pkb, nn2c, nn2d]);
    assert(h[0] == nn2h0);
    assert(h[1] == nn2h1);

    assert(ond == nn1d + nn2d); // assuming the values fit in 128 bit nums - hence onc, nn1c, nn2c are 0
    return 1;
}`;
    const artifacts = zokratesProvider.compile(source);
    const pk = await getKey(PROVING);
    const params = await getTransferZkParams(
      "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
      "5",
      "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
      "1"
    );
    const { witness, output } = zokratesProvider.computeWitness(
      artifacts,
      params
    );
    console.log("Creating proof...");
    const proof = zokratesProvider.generateProof(
      artifacts.program,
      witness,
      pk
    );
    console.log("Verifying proof...");
    const tx = await contractWithSigner.verifyTx(proof.proof, proof.inputs);
    console.log(tx);
  } catch (error) {
    console.log(error);
  }
}
main();
