'use client';
import React from 'react';
import { Box, Flex, Heading, Spacer } from '@chakra-ui/react';
import AdenaWallet from './AdenaWallet';

const Header: React.FC = () => {
  return (
    <Box bg="teal.500" px={4}>
      <Flex h={16} alignItems="center" justifyContent="space-between">
        <Heading as="h1" size="lg" color="white">
          AutoSwap
        </Heading>
        <Spacer />
        <AdenaWallet />
      </Flex>
    </Box>
  );
};

export default Header;