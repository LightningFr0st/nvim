const vsdaLocation = process.env.VSDA_NODE;
const value = process.argv[2];

if (!vsdaLocation) {
  console.error("VSDA_NODE is not set");
  process.exit(1);
}

if (!value) {
  console.error("No handshake value was provided");
  process.exit(1);
}

const vsda = require(vsdaLocation);
const signer = new vsda.signer();

process.stdout.write(signer.sign(value));
