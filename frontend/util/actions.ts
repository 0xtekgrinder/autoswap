
import { defaultTxFee, GnoJSONRPCProvider, GnoWallet, GnoWSProvider } from '@gnolang/gno-js-client';
import {
  BroadcastTxCommitResult,
  TM2Error,
  TransactionEndpoint
} from '@gnolang/tm2-js-client';
import Long from 'long';
import Config from './config';
import {
  defaultFaucetTokenKey,
} from '../types/types';
import { ErrorTransform } from './errors';

const defaultGasWanted: Long = new Long(1200_000_0);
const customTXFee = '100000ugnot'

const cleanUpRealmReturn = (ret: string, callType: string) => {
  // maketx adds and extra quote at the end of the string
  // so we need to have 2 slice values, one from 9 chars, for eval transaction
  // and one from 11 chars, for maketx
  if(ret !== undefined){
    console.log("ret ", ret)
    if (callType == "maketx"){
      return ret.slice(2, -11).replace(/\\"/g, '"');
    }
    else if (callType == "eval"){
      return ret.slice(2, -9).replace(/\\"/g, '"');
    }
  }
};

const decodeRealmResponse = (resp: string, callType: string) => {
  console.log("resp in decodeResponse ", resp)
  return cleanUpRealmReturn(atob(resp), callType);
};

const parsedJSONOrRaw = (data: string, nob64 = false, callType: string) => {
  const decoded = nob64 ? cleanUpRealmReturn(data, callType) : decodeRealmResponse(data, callType);
  try {
    return JSON.parse(decoded);
  } finally {
    return decoded;
  }
};

/**
 * Actions is a singleton logic bundler
 * that is shared throughout the game.
 *
 * Always use as Actions.getInstance()
 */
class Actions {
  private static instance: Actions;

  private static initPromise: Actions | PromiseLike<Actions>;
  private faucetToken;
  private wallet: GnoWallet | null = null;
  private provider: GnoWSProvider | null = null;
  private providerJSON: GnoJSONRPCProvider | null = null;
  
  private rpcURL: string = Config.GNO_JSONRPC_URL;  
  private faucetURL: string = Config.FAUCET_URL;
  private nextGnoRealm: string = Config.GNO_NEXT_REALM;
  
  
  private constructor() {}

  /**
   * Fetches the Actions instance. If no instance is
   * initialized, it initializes it
   */
  public static async getInstance(): Promise<Actions> {
    if (!Actions.instance) {
      Actions.instance = new Actions();
      Actions.initPromise = new Promise(async (resolve) => {
        await Actions.instance.initialize();
        resolve(Actions.instance);
      });
      return Actions.initPromise;
    } else {
      return Actions.initPromise;
    }
  }

  /**
   * Prepares the Actions instance
   * @private
   */
  private async initialize() {
    // Wallet initialization //
    this.connectWallet()

    // Faucet token initialization //
    let faucetToken: string | null = localStorage.getItem(
      defaultFaucetTokenKey
    );
    if (faucetToken && faucetToken !== '') {
      // Faucet token initialized
      this.faucetToken = faucetToken;
      try {
        // Attempt to fund the account
        await this.fundAccount(this.faucetToken);
      } catch (e) {
        
          console.log('funding error: ', e);
        
      }
    }
  }

  /**
   * Reinitialize the provider, need to call after changing rpc
   */
  private async reinitializeProvider(): Promise<void> {
    try {
        // Reinitialize the JSON RPC provider with the new URL
        this.providerJSON = new GnoJSONRPCProvider(this.rpcURL);
        if (this.wallet) {
            this.wallet.connect(this.providerJSON);
        }
        console.log("Provider reinitialized with new URL:", this.rpcURL);
    } catch (e) {
        console.error("Failed to reinitialize provider:", e);
    }
  }

  /**
   * Connects a wallet
   */
  public connectWallet() {
    if (this.wallet !== null){
      try {
        // Initialize the provider
        this.providerJSON = new GnoJSONRPCProvider(this.rpcURL)
        // Connect the wallet to the provider
        this.wallet.connect(this.providerJSON);
      } catch (e) {
        //Should not happen
        console.error('Could not create wallet from mnemonic');
      }
    }
  }

  /**
   * Funds an account via the faucet, if needed
   */
  private async fundAccount(token: string): Promise<boolean> {
    console.log("Token:", token);
    const requestOptions = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            to: await this.wallet?.getAddress()
        })
    };

    if (!this.faucetURL) {
        console.error("Faucet URL is undefined.");
        return false;
    }

    try {
        const response = await fetch(this.faucetURL, requestOptions);
        const data = await response.json();
        console.log("Faucet URL:", this.faucetURL);
        console.log("Fund Response:", JSON.stringify(data, null, 2));

        if (!response.ok) {
            console.error("Fund error:", data.message || "Unknown error");
            return false;
        }

        return true;
    } catch (error) {
        console.error("Error during fetch:", error);
        return false;
    }
  }

  /**
   * Destroys the Actions instance, and closes any running services
   */
  public destroy() {
    if (!this.provider) {
      // Nothing to close
      return;
    }
  }

  // setters 

  public setWallet(wallet: GnoWallet) {
    this.wallet = wallet;
  }

  public setRpcUrl(newRpcUrl: string): void {
    this.rpcURL = newRpcUrl;
    this.reinitializeProvider();
  }

  public setFaucetUrl(newFaucetUrl: string): void {
    this.faucetURL = newFaucetUrl;
  }

  public setNextGnoRealm(newNextGnoRealm: string): void {
    this.nextGnoRealm = newNextGnoRealm;
  }

  /**
   * Saves the faucet token to local storage
   * @param token the faucet token
   */
  public async setFaucetToken(token: string) {
    // Attempt to fund the account

    await this.fundAccount(token);
    this.faucetToken = token;
    localStorage.setItem(defaultFaucetTokenKey, token);
  }

  // getters

  /**
   * Return user Addres
   */
  public getWalletAddress() {
    return this.wallet?.getAddress();
  }

  public async getSigner() {
    return this.wallet?.getSigner()
  }

  /**
   * Return user Balance
   */
  public async getBalance() {
    return await this.wallet?.getBalance('ugnot');
  }

  // chain interactions
  // callMethod broadcasts a transaction on a realm method, uses gas
  // evaluateExpression makes a query on a realm method, doesn't use gas

  /**
   * Performs a transaction, handling common error cases and transforming them
   * into known error types.
   */
  public async callMethod(
    method: string,
    args: string[] | null,
    gasWanted: Long = defaultGasWanted
  ): Promise<BroadcastTxCommitResult> {
    const gkLog = this.gkLog();
    try {
      if (gkLog) {
        const gkArgs = args?.map((arg) => '-args ' + arg).join(' ') ?? '';
        console.log(
          `$ gnokey maketx call -broadcast ` +
            `-pkgpath ${this.nextGnoRealm} -gas-wanted ${gasWanted} -gas-fee ${defaultTxFee} ` +
            `-func ${method} ${gkArgs} test`
        );
      }
            
      const resp = (await this.wallet?.callMethod(
        this.nextGnoRealm,
        method,
        args,
        TransactionEndpoint.BROADCAST_TX_COMMIT,
        undefined,
        {
          gasFee: defaultTxFee,
          gasWanted: gasWanted
        }
      )) as BroadcastTxCommitResult;
      if (gkLog) {
        console.info('response in call:', JSON.stringify(resp));
        const respData = resp.deliver_tx.ResponseBase.Data;
        if (respData !== null) {
          console.info('response (parsed):', parsedJSONOrRaw(respData, false, "maketx"));
          return parsedJSONOrRaw(respData, false, "maketx");
        }
      }
      return resp;
    } 
    catch (err) {
      if(err !== undefined){
        if (gkLog) {
          console.log('err:', err);
        }
        let error: TM2Error;
      const ex = err as { log?: string; message?: string } | undefined;
      if (
        typeof ex?.log !== 'undefined' &&
        typeof ex?.message !== 'undefined' &&
        ex.message.includes('abci.StringError')
      ) {
        error = ErrorTransform(err as TM2Error);
      }
      if (gkLog) {
        console.log('error in maketx:', error);
      }
      throw error;
    }
    }
  }

  public async evaluateExpression(expr: string): Promise<string> {
    const gkLog = this.gkLog();
    if (gkLog) {
      const quotesEscaped = expr.replace(/'/g, `'\\''`);
      console.info(
        `$ gnokey query vm/qeval --data '${this.nextGnoRealm}.${quotesEscaped}'`
      );
    }

    const resp = (await this.providerJSON?.evaluateExpression(
      this.nextGnoRealm,
      expr
    )) as string;

    if (gkLog) {
      console.info('evaluateExpression response:', parsedJSONOrRaw(resp, true, "eval"));
    }

    // Parse the response
    return parsedJSONOrRaw(resp, true, "eval");
  }

  // utils

  public hasWallet() {
    return !!this.wallet;
  }

  private gkLog(): Boolean {
    const wnd = window as { gnokeyLog?: Boolean };
    return true;
  }

  /****************
   * Realm calls
   ****************/

  /**
   * Adds a new task
   *
   * @param taskName string - task name
   */
  
  async AddTask(
    taskName: string,
  ): Promise<any> {
    const response = await this.callMethod('AddTask', [
      taskName
    ]);
    console.log("actions AddTask response ", JSON.stringify(response))
    return response;
  }

   /**
   * Removes a task
   *
   * @param taskId string - task id
   */
  
   async RemoveTask(
    taskId: string,
  ): Promise<any> {
    const response = await this.callMethod('RemoveTask', [
      taskId
    ]);
    console.log("actions RemoveTask response ", JSON.stringify(response))
    return response;
  }

  /**
   * Updates a task
   *
   * @param taskId string - task id
   * @param taskBody string - task body
   */
  
  async UpdateTask(
    taskId: string,
    taskBody: string,
  ): Promise<any> {
    const response = await this.callMethod('EditTask', [
      taskId,
      taskBody
    ]);
    console.log("actions EditTask response ", JSON.stringify(response))
    return response;
  }

 
  /**
   * Get tasks by realm
   */
  
  async GetTasksByRealm(realmId : string): Promise<any> {
    const response = await this.evaluateExpression("GetTasksByRealm(\"" + realmId + "\")")
    console.log("actions GetTasksByRealm response ", JSON.stringify(response))
    return response;
  }

}

export default Actions;