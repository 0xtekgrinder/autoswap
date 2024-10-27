import { txIndexerUrl } from "@/config/constants";
import { Pool } from "@/types/pool";
import axios from "axios";

export async function getPools(): Promise<Pool[]> {
    const data = await axios.post(txIndexerUrl + '/graphql/query', {
        data: {
            "query": "# Get all the transactions that contain the specified Events on them.\nquery getEvents {\n  getTransactions(\n    where: {\n      \n      # Filtering by block height will speed up your queries, because it is the main internal index.\n      block_height :{\n        gt:100000\n      }\n      \n      # Only show transactions that succeeded.\n      success: {eq: true}, \n      response: {\n        events: {\n        \n          # This filter is checking that all transactions will contains a GnoEvent that \n          # is GNOSWAP type calling SetPoolCreationFee function.\n          GnoEvent: {\n            type: { eq:\"NewVault\" }\n          }\n        }\n      }\n    }\n  ) {\n    response {\n      events {\n        ... on GnoEvent {\n          type\n          func\n          attrs {\n            key\n            value\n          }\n        }\n      }\n    }\n  }\n}",
            "operationName": "getEvents"
        }
    })

    const pools = data.data.response.events.map((event: any) => {
        const pool: Pool = {
            tokenId: event.attrs[0].value,
            token0: event.attrs[1].value,
            token1: event.attrs[2].value,
            fee: parseFloat(event.attrs[3].value),
            lowerTick: parseInt(event.attrs[4].value),
            upperTick: parseInt(event.attrs[5].value),
            currentTick: 0, // TODO get current tick
            TVL: 0, // TODO get TVL
            APY: 0, // TODO get APY
            balance: 0 // TODO get balance
        }
        return pool;
    });
    return pools;
}
