package gnoswap_optimizer

func GetVault(tokenId uint64) Vault {
	vault := mustGetVault(tokenId)
	return *vault
}

func GetVaultPaused(tokenId uint64) bool {
	vault := mustGetVault(tokenId)
	return vault.paused
}

func GetVaultToken0(tokenId uint64) string {
	vault := mustGetVault(tokenId)
	return vault.token0
}

func GetVaultToken1(tokenId uint64) string {
	vault := mustGetVault(tokenId)
	return vault.token1
}

func GetVaultFee(tokenId uint64) uint32 {
	vault := mustGetVault(tokenId)
	return vault.fee
}

func GetVaultWidth(tokenId uint64) uint32 {
	vault := mustGetVault(tokenId)
	return vault.width
}

func BalanceOf(tokenId uint64, account string) string {
	vault := mustGetVault(tokenId)
	balance := mustGetBalance(vault, account)
	return balance.ToString()
}
