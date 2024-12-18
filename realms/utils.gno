package autoswap

import (
	"std"
	"strconv"

	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/uint256"
	pn "gno.land/r/gnoswap/v2/position"
)

func assertVaultPaused(vault *Vault) {
	if vault.paused {
		panic("Vault is paused")
	}
}

func mustGetVault(tokenId uint64) *Vault {
	vault, exists := vaults.Get(strconv.FormatUint(tokenId, 10))
	if !exists {
		panic(ufmt.Sprintf("Vault %d not found", tokenId))
	}
	return vault.(*Vault)
}

func mustGetRegistered(pkgPath string) GRC20Interface {
	igrc20, exists := registered.Get(pkgPath)
	if !exists {
		panic(ufmt.Sprintf("GRC20 interface for package %s not found", pkgPath))
	}
	return igrc20.(GRC20Interface)
}

func mustGetBalance(vault *Vault, account string) *uint256.Uint {
	balance, exists := vault.balances.Get(account)
	if !exists {
		panic(ufmt.Sprintf("Balance for account %s not found", account))
	}
	parsedAmount := uint256.MustFromDecimal(balance.(string))
	return parsedAmount
}

func increaseBalance(vault *Vault, account string, amount string) {
	parsedAmount := uint256.MustFromDecimal(amount)

	currentBalance := mustGetBalance(vault, account)
	currentBalance.Add(currentBalance, parsedAmount)
	vault.balances.Set(account, currentBalance.ToString())
}

func decreaseBalance(vault *Vault, account string, amount string) {
	parsedAmount := uint256.MustFromDecimal(amount)

	currentBalance := mustGetBalance(vault, account)
	currentBalance.Sub(currentBalance, parsedAmount)
	vault.balances.Set(account, currentBalance.ToString())
}

// get a percentage of the total liquidity as an uint64
func computeLiquidityRatio(tokenId uint64, balance *uint256.Uint) uint64 {
	totalLiquidity := pn.PositionGetPositionLiquidity(tokenId)

	// get a percentage of the total liquidity as an uint64
	percentage := uint256.Zero()
	percentage.Set(balance)
	percentage.MulOverflow(percentage, uint256.NewUint(100))
	percentage.Div(percentage, uint256.MustFromDecimal(totalLiquidity.ToString()))

	return percentage.Uint64()
}

func subAmounts(amount0, amount1 string) *uint256.Uint {
	amount0Parsed := uint256.MustFromDecimal(amount0)
	amount1Parsed := uint256.MustFromDecimal(amount1)

	amount0Parsed.Sub(amount0Parsed, amount1Parsed)
	return amount0Parsed
}

func mustHaveRole(account std.Address, role string) {
	if !accessControl.HasRole(std.PrevRealm().Addr(), role) {
		panic(ufmt.Sprintf("Account %s does not have role %s", account.String(), role))
	}
}
