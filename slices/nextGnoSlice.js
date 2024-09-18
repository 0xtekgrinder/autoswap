import { createSlice } from '@reduxjs/toolkit';

const nextGnoSlice = createSlice({
  name: 'nextgno',
  initialState: {
    blockchainName: undefined,
    testnet: true,
    mainnet: false,
    rpcEndpoint: "https://rpc.irreverentsimplicity.xyz",
    userGnotBalances: undefined,
    userLoggedIn: 0,
    tasks: [],
  },
  reducers: {
    setUserLoggedStatus(state, action){
      state.userLoggedIn = action.payload;
    },
    setTasks(state, action) {
      state.tasks = action.payload;
    },
    setBlockchain(state, action) {
      state.blockchainName = action.payload;
    },
    setUserGnotBalances(state, action) {
      console.log("slice userGnotBalances ", JSON.stringify(action.payload))
      state.userGnotBalances = action.payload;
    },
    setRpcEndpoint(state, action) {
      console.log("slice setRpcEndpoint ", JSON.stringify(action.payload))
      state.rpcEndpoint = action.payload;
    },
  },
});

export const { 
  setUserLoggedStatus,
  setTasks,
  setBlockchain, 
  setUserGnotBalances, 
  setRpcEndpoint } = nextGnoSlice.actions;

export default nextGnoSlice;

