import { createSlice } from '@reduxjs/toolkit';

const nextGnoSlice = createSlice({
  name: 'nextgno',
  initialState: {
    blockchainName: undefined,
    testnet: true,
    mainnet: false,
    rpcEndpoint: "https://rpc.irreverentsimplicity.xyz",
    userGnotBalances: undefined,
  },
  reducers: {
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
  setBlockchain, 
  setUserGnotBalances, 
  setRpcEndpoint } = nextGnoSlice.actions;

export default nextGnoSlice;

