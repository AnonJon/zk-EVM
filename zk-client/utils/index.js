export const shortenAddress = (addr) =>
  `${addr.substring(0, 6)}...${addr.slice(addr.length - 4)}`;
