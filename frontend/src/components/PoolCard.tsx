import React from 'react';
import { Box, Text, Button, VStack, HStack, Flex } from '@chakra-ui/react';
import { Pool } from '../types/pool';


type PoolCardProps = {
    pool: Pool;
    onDeposit: () => void;
    onWithdraw: () => void;
  };
  
  const PoolCard: React.FC<PoolCardProps> = ({ pool, onDeposit, onWithdraw }) => {
    return (
      <Flex justify="center" align="center" w="full">
        <Box borderWidth="1px" borderRadius="lg" overflow="hidden" p={4} bg="white" shadow="md" w="full" maxW="400px">
  <VStack align="start" spacing={4}>
    <Text fontSize="xl" fontWeight="bold">
      {pool.token0} / {pool.token1}
    </Text>
    <Text>Fee: {pool.fee}%</Text>
    <Text>Upper Tick: {pool.upperTick}</Text>
    <Text>Lower Tick: {pool.lowerTick}</Text>
    <Text>Current Tick: {pool.currentTick}</Text>
    <Text>TVL: ${pool.TVL.toLocaleString()}</Text>
    <Text>APY: {pool.APY}%</Text>
    <Text>Balance: {pool.balance}</Text>
    <HStack spacing={4} justify="center" w="full">
      <Button colorScheme="teal" onClick={onDeposit} flex="1">
        Deposit
      </Button>
      <Button colorScheme="red" onClick={onWithdraw} flex="1">
        Withdraw
      </Button>
    </HStack>
  </VStack>
</Box>
      </Flex>
    );
  };

export default PoolCard;