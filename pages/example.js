/* eslint-disable react/no-unknown-property */
import Head from "next/head";
import styles from "../styles/Home.module.css";
import { useEffect, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import { Box, Button, Flex, Spinner, Text, Stack } from '@chakra-ui/react';
import Menu from "../components/Menu";
import Header from "../components/Header";
import Tasks from "../components/Tasks";
import Footer from "../components/Footer";
import {fetchAllTasksByRealm} from "../util/fetchers";
import { getGNOTBalances } from "../util/tokenActions";
import { useRouter } from "next/router";

const Example = () => {
  
  const userGnotBalances = useSelector(state => state.nextgno.userGnotBalances);
  const rpcEndpoint = useSelector(state => state.nextgno.rpcEndpoint);
  const userLoggedIn = useSelector(state => state.nextgno.userLoggedIn);

  const dispatch = useDispatch();
  const router = useRouter();


  useEffect( () => {
      console.log("rpcEndpoint in useEffect, flip.js ", rpcEndpoint)
      getGNOTBalances(dispatch, (result) => {
        if (result.success) {
            alert(result.message);
        } else {
            alert(`Error: ${result.message}`);
        }
    });
  }, [rpcEndpoint, dispatch])

  useEffect( () => {
    if(userLoggedIn === "1"){
      console.log("trigger")
      fetchAllTasksByRealm(dispatch, "1")
      
    }
    if(userLoggedIn === "0"){
      console.log("unlogged")
    }
    
  }, [userLoggedIn, dispatch])

  

  
  

  return (
    <div className={styles.container}>
      <Head>
        <title>Next Gno Dapp</title>
        <meta name="description" content="Entry point" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Header userGnotBalances={userGnotBalances}/>
    
        <div className="grid flex grid-cols-5">
      
        <div className="bg-white-100">
          <Menu currentPage="/example"/>
        </div>

          <div className="col-span-4 flex flex-col items-center pt-10">
            <Tasks />
          </div>
        </div>
        <div className="col-span-5 pt-20">
            <Footer/>
        </div>
    </div>
  );
}

export default Example;
