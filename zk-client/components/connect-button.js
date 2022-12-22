import {
  Box,
  Button,
  ButtonProps,
  Modal,
  ModalBody,
  ModalCloseButton,
  ModalContent,
  ModalFooter,
  ModalHeader,
  ModalOverlay,
  Stack,
  useDisclosure,
} from "@chakra-ui/react";
import { chain, useConnect, useAccount } from "wagmi";

export const ConnectButton = (buttonProps) => {
  const { connector: activeConnector, isConnected } = useAccount();

  const { connect, error, connectors, isLoading, pendingConnector } =
    useConnect({
      chainId: chain.goerli.id,
    });
  const { isOpen, onOpen, onClose } = useDisclosure();
  const { children } = buttonProps;
  return (
    <>
      <Button onClick={onOpen} {...buttonProps} variant="base">
        {children}
      </Button>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent bg="rgb(123, 63, 228)">
          <ModalHeader color="white">Connect</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <Stack>
              {connectors &&
                connectors.map((connector) => (
                  <Button
                    variant="wallet"
                    disabled={!connector.ready}
                    key={connector.id}
                    onClick={() => connect({ connector })}
                  >
                    {connector.name}
                    {isLoading &&
                      pendingConnector?.id === connector.id &&
                      " (connecting)"}
                  </Button>
                ))}
              {error && <Box>{error?.message ?? "Failed to connect"}</Box>}
            </Stack>
          </ModalBody>
          <ModalFooter />
        </ModalContent>
      </Modal>
    </>
  );
};
