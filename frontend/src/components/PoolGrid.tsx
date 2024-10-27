'use client';
import React from 'react';
import { SimpleGrid, Box, useDisclosure } from '@chakra-ui/react';
import PoolCard from './PoolCard';
import { useState } from 'react';
import { Pool } from '../types/pool';
import DepositModal from './DepositModal';
import WithdrawModal from './WithdrawModal';

const PoolGrid: React.FC= () => {
    const [pools] = useState<Pool[]>([
        {
            token0: 'ETH',
            token1: 'USDC',
            fee: 0.3,
            upperTick: 1000,
            lowerTick: 500,
            currentTick: 750,
            TVL: 1000000,
            APY: 100,
            balance: 1000
        },
        {
            token0: 'ETH',
            token1: 'USDT',
            fee: 0.3,
            upperTick: 1000,
            lowerTick: 500,
            currentTick: 750,
            TVL: 1000000,
            APY: 100,
            balance: 1000
        }
    ]);

    const { isOpen: isOpenDeposit, onOpen: onOpenDeposit, onClose: onCloseDeposit } = useDisclosure();
    const { isOpen: isOpenWithdraw, onOpen: onOpenWithdraw, onClose: onCloseWithdraw } = useDisclosure();

    const onDeposit = (pool: Pool) => {
        console.log('Deposit', pool);
        onOpenDeposit();
    }

    const onWithdraw = (pool: Pool) => {
        console.log('Withdraw', pool);
        onOpenWithdraw();
    }

  return (
    <>
    <DepositModal isOpen={isOpenDeposit} onClose={onCloseDeposit} />
    <WithdrawModal isOpen={isOpenWithdraw} onClose={onCloseWithdraw} />
    <SimpleGrid columns={{ sm: 1, md: 2, lg: 3 }} spacing={8} w="full">
      {pools.map((pool) => (
          <Box key={`${pool.token0}-${pool.token1}`} display="flex" justifyContent="center">
          <PoolCard
            pool={pool}
            onDeposit={() => onDeposit(pool)}
            onWithdraw={() => onWithdraw(pool)}
            />
        </Box>
      ))}
    </SimpleGrid>
      </>
  );
};

export default PoolGrid;