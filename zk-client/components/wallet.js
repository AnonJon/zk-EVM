import { shortenAddress } from "../utils";
import { ConnectButton } from "./connect-button";
import { TriangleDownIcon } from "@chakra-ui/icons";
import {
  Avatar,
  AvatarBadge,
  Badge,
  Button,
  HStack,
  Menu,
  MenuButton,
  MenuDivider,
  MenuGroup,
  MenuItem,
  MenuList,
  Text,
} from "@chakra-ui/react";
import { useIsMounted } from "../hooks/app-hooks";
import {
  useAccount,
  useDisconnect,
  useEnsAvatar,
  useEnsName,
  useNetwork,
} from "wagmi";

export const Wallet = ({ width }) => {
  const { address, isConnected } = useAccount();
  const { data: ensName } = useEnsName();
  const { data: ensAvatar } = useEnsAvatar();
  const { disconnect } = useDisconnect();

  const signOut = () => {
    disconnect();
  };
  const {
    switchNetwork,
    chains,
    activeChain,
    pendingChainId,
    isLoading: networkIsLoading,
  } = useNetwork();
  const isMounted = useIsMounted();
  console.log("mounted", isMounted());
  return isConnected && isMounted() ? (
    <Menu>
      <MenuButton
        as={Button}
        backgroundColor="rgb(123, 63, 228)"
        rounded="full"
        pl={4}
        color="black"
      >
        <HStack mx={-1} spacing={1}>
          <Text fontSize={["md", "lg"]} mr={1}>
            {ensName ||
              (width > 600
                ? shortenAddress(address)
                : shortestAddress(address))}
          </Text>
          <Avatar fontWeight="700" size="sm" src={ensAvatar || undefined}>
            <AvatarBadge boxSize="1.25em" bg="purple.500" />
          </Avatar>
          <TriangleDownIcon ml={3} mr={-1} w={3} color="gray.400" />
        </HStack>
      </MenuButton>
      <MenuGroup />
      <MenuList bg="rgb(123, 63, 228)">
        <MenuGroup title="Network">
          {chains &&
            chains.map((chain) => (
              <MenuItem
                key={`network-${chain.id}`}
                onClick={() =>
                  activeChain?.id !== chain.id && switchNetwork?.(chain.id)
                }
              >
                <Text pl="3">
                  {chain.name}
                  <Badge
                    variant="outline"
                    colorScheme="green"
                    ml={2}
                    hidden={activeChain?.id !== chain.id}
                  >
                    Connected
                  </Badge>
                  <Badge
                    variant="outline"
                    colorScheme="yellow"
                    ml={2}
                    hidden={!networkIsLoading || pendingChainId !== chain.id}
                  >
                    Loading...
                  </Badge>
                </Text>
              </MenuItem>
            ))}
        </MenuGroup>
        <MenuDivider />
        <MenuItem onClick={() => signOut()}>Disconnect</MenuItem>
      </MenuList>
    </Menu>
  ) : (
    <ConnectButton>Connect</ConnectButton>
  );
};

export const shortestAddress = (addr) => `${addr.substring(0, 5)}`;
