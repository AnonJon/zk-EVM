const crypto = require("crypto");

function test() {
  const buf = Buffer.from(
    "4fdd54a50623a7c7b5b3055700eb4872356bd5b3000000000000000000000000" +
      "0000000000000000000000000000000000000000000000000000000000000001",
    "hex"
  );
  const digest = crypto.createHash("sha256").update(buf).digest("hex");
  console.log(digest);
}

test();
