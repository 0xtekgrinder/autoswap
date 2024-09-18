import Actions from "./actions";  
import { 
    setTasks, 
 } from "../slices/nextGnoSlice";


export const fetchAllTasksByRealm = async (dispatch, realmId) => {

    const actions = await Actions.getInstance();
    try {
        actions.GetTasksByRealm(realmId).then((response) => {
        console.log("getTasksByRealm response in fetchers, for realm: " +  response + " " + realmId);
            if (response !== undefined){
            let parsedResponse = JSON.parse(response);
            
            if(parsedResponse.tasks !== undefined){  
            console.log("parseResponse", JSON.stringify(response, null, 2))
            if (realmId == "1"){
                dispatch(setTasks(parsedResponse.tasks))
            }
            }
        }
    });
    } catch (err) {
        console.log("error in calling getAllTasks", err);
    }
};