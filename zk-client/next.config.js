/** @type {import('next').NextConfig} */

function throwEnv(envVar) {
  if (!process.env[envVar]) {
    throw new Error(`Missing environment variable: ${envVar}`);
  }
  return process.env[envVar];
}
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  env: {
    NEXT_PUBLIC_GOERLI_RPC: throwEnv("NEXT_PUBLIC_GOERLI_RPC"),
  },
};

module.exports = nextConfig;
