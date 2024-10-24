# AutoSwap

## Description

AutoSwap is a DeFi protocol built on top of [gnoswap](https://github.com/gnoswap-labs/gnoswap) that allows users to enter in a gnoswap's pool and automatically reposition their fund to stay in the active tick range of the pool.

This is called Automated Liquidity Management (ALM).

## How it works

1. Admin deploy a new vault with the desired pool by specifying token0, token1 and fee.
2. User deposit token0 and token1 into the vault.
3. Keeper will monitor the vault and reposition the fund to stay in the active tick range of the pool.
4. User can claim the fees accrued by his position inside the vault at any time.
5. User can withdraw their fund at any time.

## Get Started

### Contracts

To tests the contracts, you first need to clone the gnoswap repository and add it to the gno root directory in the `examples` folder with the corresponding path between /p and /r.

You also need to do the same for foo and bar located at `contracts/mock/foo` and `contracts/mock/bar`

Then you can run the following commands:

```bash
gno test ./contracts
```

### Frontend

To run the frontend, you first need `pnpm` installed. You can install it by running the following command:

```bash
npm install -g pnpm
```

And then you can run the following commands to install the dependencies:

```bash
cd frontend
pnpm install
```

Finaly, you can run the frontend by running the following command:

```bash
pnpm build
pnpm start
```

Or when you are developing, you can run the following command:

```bash
pnpm dev
```
