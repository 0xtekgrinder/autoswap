package gnoswap_optimizer

import (
	"fmt"
	"strconv"

	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/v2/position"
)

func assertVaultPaused(vault *Vault) {
	if vault.paused {
		panic("Vault is paused")
	}
}

func mustGetVault(tokenId uint64) *Vault {
	vault, exists := vaults.Get(strconv.FormatUint(tokenId, 10))
	if !exists {
		panic(fmt.Sprintf("Vault %d not found", tokenId))
	}
	return vault.(*Vault)
}

func mustGetBalance(vault *Vault, account string) *u256.Uint {
	balance, exists := vault.balances.Get(account)
	if !exists {
		panic(fmt.Sprintf("Balance for account %s not found", account))
	}
	parsedAmount, err := u256.FromDecimal(balance.(string))
	if err != nil {
		panic(err)
	}
	return parsedAmount
}

func increaseBalance(vault *Vault, account string, amount string) {
	parsedAmount, err := u256.FromDecimal(amount)
	if err != nil {
		panic(err)
	}

	currentBalance := mustGetBalance(vault, account)
	currentBalance.Add(currentBalance, parsedAmount)
	vault.balances.Set(account, currentBalance.ToString())
}

// get a percentage of the total liquidity as an uint64
func computeLiquidityRatio(tokenId uint64, balance *u256.Uint) uint64 {
	totalLiquidity := position.PositionGetPositionLiquidity(tokenId)

	// get a percentage of the total liquidity as an uint64
	percentage := new(u256.Uint)
	percentage.Set(balance)
	percentage.Mul(percentage, u256.NewUint(100))
	percentage.Div(percentage, totalLiquidity)

	return percentage.Uint64()
}
