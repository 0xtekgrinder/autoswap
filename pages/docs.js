import styles from "../styles/Home.module.css";
import Menu from '../components/Menu';
import Footer from '../components/Footer';
import { Box, Text } from "@chakra-ui/react";
import { useSelector, useDispatch } from 'react-redux';
import { useEffect } from "react";
import Header from "../components/Header";
import { getGNOTBalances } from "../util/tokenActions";

export default function Tutorial() {
  const userGnotBalances = useSelector(state => state.nextgno.userGnotBalances);
  const rpcEndpoint = useSelector(state => state.nextgno.rpcEndpoint);
  const dispatch = useDispatch()
  useEffect( () => {
    console.log("rpcEndpoint in useEffect, docs.js ", rpcEndpoint)
    getGNOTBalances(dispatch);
}, [rpcEndpoint])

  return (
    <div className={styles.container}>
      <Header userGnotBalances={userGnotBalances}/>
      
      <div className="grid flex grid-cols-5">
      
        <div className="bg-white-100 col-span-1">
        <Menu />
        </div>


    <div className="col-span-4 mr-12 ml-12">
        <Box className="justify-end" borderBottom="1px solid white" mb={4} >
          <Text fontSize="2xl" fontWeight="bold" textAlign="right" mb={4} mr={4}>
            What is Next Gno Dapp?
          </Text>
        </Box>
        <Box className="justify-start" borderBottom="1px solid gray" mt={8}>
          <Text fontSize="xl" fontWeight="bold" textAlign="left" mb={4} mr={4}>
            From idea to code, the fast route
          </Text>
          <Text fontSize="lg" textAlign="left" mt={10} mb={4} mr={4}>
            Next Gno Dapp is a next.js based scaffold for a dapp on the Gno blockchain. It features:
            </Text>
            <ul>
              <li>next.js app, with all the expected goodies (router, .env integration)</li>
              <li>react-redux: keep your data persistent across sessions</li>
              <li>gno-js / tm.js integration</li>
              <li>in-browser wallet creation</li>
              <li>encrypting / decrypting wallet mnemonic and saving in indexed.db</li>
              <li>automatic faucet funding (if using testnet)</li>
              <li>backend calls abstracted: create your React functions on top of stubs defined in actions.ts</li>
              <li>chakra/ui integration for rich, fast UI development</li>
            </ul>
        </Box>
    </div>

    </div>
        <div className="col-span-5 pt-20">
            <Footer/>
        
        </div>
    </div>
  );
}
