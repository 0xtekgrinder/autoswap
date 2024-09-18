# Next Gno Dapp

<img width="1538" alt="Screenshot 2024-09-18 at 12 00 39 PM" src="https://github.com/user-attachments/assets/1c78db9a-c6b3-4d67-a384-13152e740a7b">

### Next Gno Dapp is a next.js based scaffold for a dapp on the Gno blockchain. It features:
                    
- next.js app, with all the expected goodies (router, .env integration)
- react-redux: keep your data persistent across sessions
- gno-js / tm.js integration
- in-browser wallet creation
- encrypting / decrypting wallet mnemonic and saving in indexed.db
- automatic faucet funding (if using testnet)
- abstracted backend calls: create your React functions on top of stubs defined in actions.ts
- chakra/ui integration for rich, fast UI development

### Pre-requisites, defaults

Next Gno Dapp uses both `.env` files for local / prod developments and a simple typescript Config. Editing those values should be enough to get you started.

You will need, though:

- an rpc node to connect with
- a faucet that can work with that rpc node (if using testnet)
- a realm to make transactions on, or query (the example provided uses `zentasktic_core` or `zentasktic_project`)

### Basic wallet flow

Under the hood, Next Gno Dapp uses `gno-js` / `tm-js` libraries to create an in-browser wallet. The onboarding flow simplifies this process by prompting the user to create a simple password. Using this password (and some salt), the wallet mnemonic is encrypted and saved in user's `indexeded.db` storage (the mnemonic never leaves the browser). Once the wallet is created, a check is made for user's balances, and, if these are under 10 GNOT, a request to the faucet is made, to fund the user account, with 1000 GNOT. This should be enough for most development cases.  

Subsequent accesses will require only the password to access the dapp.

### Redux integration

A very simple redux implementation is created under `slices`, `state` and `store`. The provided code should be enough to get you going with your own data storage needs.

PRs welcome.