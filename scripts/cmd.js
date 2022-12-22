const crypto = require("crypto");
const BN = require("bn.js");

function getSecretZokratesParams(concat) {
  return [
    concat.slice(0, 32),
    concat.slice(32, 64),
    concat.slice(64, 96),
    concat.slice(96),
  ];
}

function getPublicZokratesParams(hexPayload) {
  const buf = Buffer.from(hexPayload, "hex");
  const digest = crypto.createHash("sha256").update(buf).digest("hex");

  return [digest.slice(0, 32), digest.slice(32)];
}

function getHexPayload(from, amount) {
  let paddedAddress = new BN(from, 16).toString(16, 64);
  let paddedAmount = new BN(amount, 16).toString(16, 64);
  return paddedAddress + paddedAmount;
}

function getNoteParams(from, amount) {
  let hexPayload = getHexPayload(from, amount);
  let zkParams = getPublicZokratesParams(hexPayload).concat(
    getSecretZokratesParams(hexPayload)
  );
  return zkParams;
}

function printZokratesCommand(params) {
  let s = [];
  params.forEach((p) => {
    s.push(`${new BN(p, 16).toString(10)}`);
  });
  return s;
}

const getTransferZkParams = async (from, fromAmount, to, toAmount) => {
  from = from.slice(2);
  to = to.slice(2);

  let change = parseInt(fromAmount) - parseInt(toAmount);
  const params = getNoteParams(from, fromAmount).concat(
    getNoteParams(to, toAmount)
  );
  let leftOver = getNoteParams(from, change);
  // for the leftover change note, first 2 params (spender public key) are the same. delete elements at 2, 3 index
  leftOver.splice(2, 2);
  return printZokratesCommand(params.concat(leftOver));
};

module.exports = {
  getTransferZkParams,
};
