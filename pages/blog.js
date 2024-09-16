/* eslint-disable react/no-unknown-property */
import Head from "next/head";
import styles from "../styles/Home.module.css";
import { useEffect, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import { Box, Button, Flex, Spinner, Text, Stack } from '@chakra-ui/react';
import Menu from "../components/Menu";
import Header from "../components/Header";
import Footer from "../components/Footer";
import Actions from "../util/actions";
import { getGNOTBalances } from "../util/tokenActions";
import { useRouter } from "next/router";

const Blog = () => {
  
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
    
      
    }
    if(userLoggedIn === "0"){
      console.log("unlogged")
    }
    
  }, [userLoggedIn, dispatch])

  

  async function flipTiles(withPositions){
    const actions = await Actions.getInstance();
    if(actions.hasWallet()){
      const playerAddress = await actions.getWalletAddress();
      const processedPositions = JSON.stringify(withPositions);
      console.log('currentGameId in flipTiles ', currentGameId)
      
      try {
        actions.flipTiles(playerAddress, currentGameId, processedPositions).then((response) => {
          console.log("Game response in flip.js flipTiles", response);
          let parsedResponse = JSON.parse(response);
          console.log("parsedResponse", parsedResponse)
          
          // this is the blockchain solved matrix
          var tileMatrixCopy = parsedResponse.solvedGameBoard;
          // we get non-zero values from chain
          if (
            parsedResponse.gameBoard[withPositions[0]] ===
            parsedResponse.gameBoard[withPositions[1]] &&
            parsedResponse.gameBoard[withPositions[0]] !== 0 &&
            parsedResponse.gameBoard[withPositions[1]] !== 0
          ) {
            // this is the blockchain solved matrix
            setTileMatrix(parsedResponse.solvedGameBoard);
          }
          // we get zero values from chain, we're in quantum state, and
          // we don't have equal numbers, display quantum flickering visual
          else if (
            parsedResponse.gameBoard[withPositions[0]] ===
            parsedResponse.gameBoard[withPositions[1]] &&
            parsedResponse.gameBoard[withPositions[0]] === 0 &&
            parsedResponse.gameBoard[withPositions[1]] === 0
          ) {
            // add a timeout function, so the numbers are visible for a while
            tileMatrixCopy[withPositions[0]] = -2;
            tileMatrixCopy[withPositions[1]] = -2;
            setTileMatrix(tileMatrixCopy);

            // wait 2 secs, then update with the solved tile matrix
            setTimeout(() => {
              console.log("Delayed for 2 seconds.");
              var tileMatrixCopy1 = [...parsedResponse.solvedGameBoard];
              tileMatrixCopy1[withPositions[0]] = 0;
              tileMatrixCopy1[withPositions[1]] = 0;
              setTileMatrix(tileMatrixCopy1);
            }, 1000);
          } else {
            // add a timeout function, so the numbers are visible for a while
            tileMatrixCopy[withPositions[0]] =
            parsedResponse.gameBoard[withPositions[0]];
            tileMatrixCopy[withPositions[1]] =
            parsedResponse.gameBoard[withPositions[1]];
            setTileMatrix(tileMatrixCopy);

            // wait 2 secs, then update with the solved tile matrix
            setTimeout(() => {
              console.log("Delayed for 2 seconds.");
              var tileMatrixCopy1 = [...parsedResponse.solvedGameBoard];
              tileMatrixCopy1[withPositions[0]] = 0;
              tileMatrixCopy1[withPositions[1]] = 0;
              setTileMatrix(tileMatrixCopy1);
            }, 2000);
          }
          if(parsedResponse.gameStatus === "finished"){
            setGameStatus("Flippando solved, all tiles uncovered. Congrats!");
          }
        
        });
      } catch (err) {
        console.log("error in calling flipTiles", err);
      }
    }
  }

  async function mintNFT(gameId) {
    const actions = await Actions.getInstance();
    if(actions.hasWallet()){
      const playerAddress = await actions.getWalletAddress();
      setGameStatus("Hang on, we're minting this...");
      setIsMintingNFT(true)
      try {
        actions.createNFT(playerAddress, gameId).then((response) => {
          console.log("mintNFT response in Flip", response);
          let parsedResponse = JSON.parse(response);
          console.log("parseResponse", parsedResponse)
          if(parsedResponse.error === undefined){
            setGameStatus("Board minted. Flippando is now in an undefined state.")
            if(gameLevel === 16){
              updateLevel1Board()
            }
            if(gameLevel === 64){
              updateLevel2Board()
            }
            
            fetchUserNFTs()
            getGNOTBalances(dispatch);
            fetchUserFLIPBalances(dispatch);
            setIsLoadingUserGames(true)
            getUserGamesByStatus()
            setIsMintingNFT(false)
          }
        });
      } catch (err) {
        console.log("error in calling mintNFT", err);
        setGameStatus("There was an error minting this NFT.");
      }
    }
  }

  // pure react code
  

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
          <Menu currentPage="/flip"/>
        </div>

        <div className="col-span-3 flex flex-col items-center pt-10">
        </div>
        
        {/* levels */}
        <div className="col-span-1 flex flex-col items-start pt-10">
        
        </div>
        </div>
        <div className="col-span-5 pt-20">
            <Footer/>
        </div>
    </div>
  );
}

export default Blog;
