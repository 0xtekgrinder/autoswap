import Actions from "./actions";
import { setUserGnotBalances} from '../slices/nextGnoSlice';

export const getGNOTBalances = async (dispatch, callback) => {
    console.log(typeof dispatch); 
    const actions = await Actions.getInstance();
    const playerAddress = await actions.getWalletAddress();
    if(playerAddress !== undefined){
      try {
          const response = await actions.getBalance();
          console.log("getGNOTBalances response in Flip", response);
          let parsedResponse = JSON.parse(response);
          console.log("parseResponse", JSON.stringify(parsedResponse, null, 2));
          dispatch(setUserGnotBalances(parsedResponse / 1000000));
          
          if (parsedResponse <= 1000000) {
              const fundResult = await actions.fundAccount("flippando");
              if (fundResult) {
                  console.log("Account funded successfully.");
                  if (callback) callback({ success: true, message: "Account funded successfully." });
              } else {
                  console.log("Failed to fund account.");
                  if (callback) callback({ success: false, message: "Failed to fund account." });
              }
          }
      } catch (err) {
          console.log("error in calling getGNOTBalances", err);
          if (callback) callback({ success: false, message: err.message });
      }
    }
};


  