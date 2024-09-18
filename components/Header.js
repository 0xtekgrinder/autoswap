import React from "react";
import { Flex, Box, Text, Spacer, Image } from '@chakra-ui/react';
import { useSelector } from "react-redux";
import PasswordProtectedLogin from './PasswordProtectedLogin';
import Wallet from "./Wallet";


const Header = ({ userGnotBalances }) => {
    const userLoggedIn = useSelector(state => state.nextgno.userLoggedIn);

    return (
        <Flex align="center" p="3" bg="transparent" boxShadow="sm" alignItems="flex-start">
          <Box display="flex" alignItems="flex-start" flexDirection={"column"}>
            <Text fontSize="5xl" fontWeight="bold">{process.env.NEXT_PUBLIC_DAPP_NAME}</Text>
            <Text fontSize="xs" fontWeight="italic">{process.env.NEXT_PUBLIC_DAPP_SUBTITLE}</Text>
          </Box>
          <Spacer />
          {userLoggedIn === "1" ? <Wallet userGnotBalances={userGnotBalances}/> : <PasswordProtectedLogin />}
        </Flex>
      );
}

export default Header;