const BN = require("bn.js");

async function execute() {
  const accounts = await web3.eth.getAccounts();
  // console.log(accounts)
  const instance = await contractArtifact.deployed();
  let enc = await encrypt(accounts[0].slice(2), "AF");
  console.log("enc", enc);
  const tx = await instance.createNoteDummy(accounts[0], "0xaf", enc);
  console.dir(tx, { depth: null });
}

async function encrypt(address, _amount) {
  // 20 12
  let amount = new BN(_amount, 16).toString(16, 24); // 12 bytes = 24 chars in hex
  const payload = address + amount;
  return payload;
  // console.log('enc payload', payload)
  // const encryptedNote = await web3.eth.accounts.encrypt('0x' + payload, 'vitalik')
  // return JSON.stringify(encryptedNote);
}

console.log(encrypt("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "5"));
