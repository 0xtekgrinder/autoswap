import React, {useState, useEffect} from "react";
import { FaWallet, FaPowerOff} from 'react-icons/fa';
import { Icon, Select, Button } from "@chakra-ui/react";
import { useSelector, useDispatch } from "react-redux";
import { setRpcEndpoint, 
  setNextGnoRealm,
  setUserLoggedStatus, 
  setUserGnotBalances, 
  } from "../slices/nextGnoSlice";
import Actions from "../util/actions";
import Config from '../util/config';
import AddressDisplay from "../components/AddressDisplay";
//import AdenaWallet from "./AdenaWallet";


const Wallet = ({ userGnotBalances }) => {

    const dispatch = useDispatch();
    const rpcEndpoint = useSelector(state => state.nextgno.rpcEndpoint);
    
    const [address, setAddres] = useState("")

    useEffect( () => {
      setPlayerAddress()
    })
    
    const setPlayerAddress = async () => {
      const actions = await Actions.getInstance();
      if(actions.hasWallet()){
        const playerAddress = await actions.getWalletAddress();
        setAddres(playerAddress);
      }
      else {
        await dispatchLogout()
        dispatch(setUserLoggedStatus("0"))
      }
    }

    const handleNetworkChange = async (event) => {
      const newNetwork = event.target.value;
      console.log("newNetwork, ", newNetwork)
      dispatch(setRpcEndpoint(newNetwork))
      const actionsInstance = await Actions.getInstance();
      let faucetUrl = "https://faucet.irreverentsimplicity.xyz";
      let nextGnoRealm = "gno.land/r/zentasktic/zentasktic_project";
      if (newNetwork === "http://localhost:26657"){
        faucetUrl = "http://127.0.0.1:5050";
        nextGnoRealm = "gno.land/r/demo/zentasktic_core"
      } else if (newNetwork === "https://rpc.irreverentsimplicity.xyz") {
        faucetUrl = "https://faucet.irreverentsimplicity.xyz";
        nextGnoRealm = "gno.land/r/zentasktic/zentasktic_project"
      } 
      actionsInstance.setFaucetUrl(faucetUrl);
      actionsInstance.setNextGnoRealm(nextGnoRealm);
      actionsInstance.setRpcUrl(newNetwork);
    };

    const dispatchLogout = async () => {
      const actions = await Actions.getInstance();
      actions.setWallet(null)
      // reset all state, except rpc node
      dispatch(setUserGnotBalances(undefined))
      dispatch(setUserLoggedStatus("0"))
    }

    const showLocalOption = process.env.NEXT_PUBLIC_SHOW_LOCAL_OPTION === 'true';
    const displayDropDown = process.env.NEXT_PUBLIC_SHOW_DROP_DOWN !== 'false';
    console.log("displayDropDown ", displayDropDown)
    
    return (
      <div>
      {/*<AdenaWallet/>*/}
      <div className="grid grid-cols-5 pb-10 justify-end">
        <div className="col-span-5 flex justify-end pr-10">
          <div className="rounded-md flex flex-row justify-center items-center mt-3 p-2 mr-3 bg-black-400border border-purple-400" style={{ borderWidth: '0.5px' }}>
            <Icon as={FaWallet} w={6} h={6} alignSelf="left" color={'purple.200'} pr={1}/>
            <button className="text-sm font-small gap-6 text-white border-transparent focus:outline-none">
              {userGnotBalances} GNOT
            </button>
          </div>
          <div className="rounded-md flex flex-row justify-center items-center mt-3 p-0 bg-black-400border border-purple-400" style={{ borderWidth: '0.5px' }}>
            <Button 
              bgColor={"transparent"}
              _hover={"transparent"}
              size={"xs"}
              onClick={dispatchLogout}>
              <Icon as={FaPowerOff} w={4} h={4} alignSelf="left" color={'purple.200'}/>
            </Button>
          </div>
        </div>
        <div className="col-span-5 flex justify-end pr-10 pt-2">
          <AddressDisplay address={address} />
        </div>
        {displayDropDown && 
          <div className="col-span-5 flex justify-end pr-10 pt-2">
            <Select onChange={handleNetworkChange} value={rpcEndpoint}
            size="sm"
            fontSize="sm"
            backgroundColor="purple.700"
            color="white"
            borderColor="purple.500"
            _hover={{ bg: 'purple.600' }}
            _focus={{ boxShadow: 'outline' }}>
            <option value="https://rpc.irreverentsimplicity.xyz" >IrreverentSimplicity RPC</option>
            {showLocalOption && <option value="http://localhost:26657">Local node</option>}
            
          </Select>
          </div>
        }
      </div>
      </div>
      )
}

export default Wallet