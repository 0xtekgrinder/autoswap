import PoolGrid from "@/components/PoolGrid";
import Header from "../components/Header";
import { Box, Flex } from "@chakra-ui/react";

export default function Home() {
  return (
    <Flex direction="column" align="center">
      <Box w="full">
        <Header />
      </Box>
      <Box w="full" maxW="1200px" mt={8}>
        <PoolGrid />
      </Box>
    </Flex>
  );
}
