import { Flex, Button, Link } from "@chakra-ui/react";

export const StandardMenu = ({ width }) => {
  return (
    <Flex gap={["0", "0", "0", "0.75rem", "1rem"]} bg="white">
      <Flex
        justifyContent={width < 600 ? "center" : "left"}
        alignItems="space-between"
        gap="1rem"
      ></Flex>
      <Link href="/dashboard">
        <Button variant="ghost" bg="none">
          Dashboard
        </Button>
      </Link>
      {/* <Link href="/coming-soon">
        <Button variant="base">Create Event</Button>
      </Link> */}
    </Flex>
  );
};
