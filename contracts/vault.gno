package gnoswap_optimizer

import (
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/acl"
	"gno.land/p/demo/avl"
	u256 "gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/v2/position"
)

var (
	vaults        avl.Tree // tokenId -> *Vault
	accessControl acl.Directory
)

func init() {
	accessControl.AddUserPerm(std.PrevRealm().Addr(), "role", "admin")
}

/**
 * USER FUNCTIONS
 */

// DepositMulti deposits tokens into a vault
// @param tokenId uint64 the vault id
// @param _amount0 string the amount of token0 to deposit
// @param _amount1 string the amount of token1 to deposit
func DepositMulti(tokenId uint64, _amount0 string, _amount1 string) {
	vault := mustGetVault(tokenId)
	assertVaultPaused(vault)

	caller := std.PrevRealm().Addr()

	// Pull tokens from the caller
	transferFromByRegisterCall(vault.token0, caller, std.CurrentRealm().Addr(), _amount0)
	transferFromByRegisterCall(vault.token1, caller, std.CurrentRealm().Addr(), _amount1)

	// Approve the pool contract to spend the tokens
	poolAddr := std.DerivePkgAddr("gno.land/r/gnoswap/v2/pool")
	approveByRegisterCall(vault.token0, poolAddr, _amount0)
	approveByRegisterCall(vault.token1, poolAddr, _amount1)

	_, liquidity, _, _, _ := position.IncreaseLiquidity(tokenId, _amount0, _amount1, _amount0, _amount1, time.Now().Unix()+1)

	increaseBalance(vault, caller.String(), liquidity)

	std.Emit("Deposit", caller.String(), strconv.FormatUint(tokenId, 10), _amount0, _amount1, liquidity)
}

// DepositSingle deposits a single token into a vault
// @param tokenId uint64 the vault id
// @param token string the token to deposit
// @param amount string the amount of token to deposit
func DepositSingle(tokenId uint64, token string, amount string) {
	vault := mustGetVault(tokenId)
	assertVaultPaused(vault)

	// TODO swap token to token0 or token1 if needed
}

// Withdraw withdraws tokens from a vault
// @param tokenId uint64 the vault id
// @param amount string the amount of liquidity to withdraw
//
// panic if the amount is greater than the caller's balance
func Withdraw(tokenId uint64, amount string) {
	vault := mustGetVault(tokenId)
	caller := std.PrevRealm().Addr()
	balance := mustGetBalance(vault, caller.String())
	parsedAmount, err := u256.FromDecimal(amount)
	if err != nil {
		panic(err)
	}
	if balance.Cmp(parsedAmount) < 0 {
		panic("insufficient balance")
	}

	liquidityRatio := computeLiquidityRatio(tokenId, parsedAmount)
	_, liquidity, _, _, amount0, amount1, _ := position.DecreaseLiquidity(tokenId, liquidityRatio, u256.NewUint(0).ToString(), u256.NewUint(0).ToString(), time.Now().Unix()+1, false)

	// Transfer tokens to the caller
	transferByRegisterCall(vault.token0, caller, amount0)
	transferByRegisterCall(vault.token1, caller, amount1)

	std.Emit("Withdraw", caller.String(), strconv.FormatUint(tokenId, 10), amount0, amount1, liquidity)
}

func Compound(tokenId uint64) {
	vault := mustGetVault(tokenId)

	// TODO implement
}

/**
 * ADMIN FUNCTIONS
 */

// NewVault creates a new vault
// @param token0 string the address of the first token
// @param token1 string the address of the second token
// @param fee uint32 the fee of the pool
// @param tickLower int32 the lower tick of the pool
// @param tickUpper int32 the upper tick of the pool
// @param _amount0 string the amount of token0 to deposit
// @param _amount1 string the amount of token1 to deposit
func NewVault(
	token0 string,
	token1 string,
	fee uint32,
	tickLower int32,
	tickUpper int32,
	_amount0 string, // *u256.Uint
	_amount1 string, // *u256.Uint
) {
	caller := std.PrevRealm().Addr()
	accessControl.HasRole(caller, "admin")

	// Pull tokens from the caller
	transferFromByRegisterCall(token0, std.PrevRealm().Addr(), std.CurrentRealm().Addr(), _amount0)
	transferFromByRegisterCall(token1, std.PrevRealm().Addr(), std.CurrentRealm().Addr(), _amount1)

	// Approve the pool contract to spend the tokens
	poolAddr := std.DerivePkgAddr("gno.land/r/gnoswap/v2/pool")
	approveByRegisterCall(token0, poolAddr, _amount0)
	approveByRegisterCall(token1, poolAddr, _amount1)

	tokenId, liquidity, _, _ := position.Mint(token0, token1, fee, tickLower, tickUpper, _amount0, _amount1, _amount0, _amount1, time.Now().Unix()+1, std.CurrentRealm().Addr().String())

	// Create the vault and set the admin's balance
	vault := &Vault{
		balances: avl.NewTree(),
		paused:   false,
		token0:   token0,
		token1:   token1,
		fee:      fee,
	}
	vault.balances.Set(caller.String(), liquidity)

	vaults.Set(strconv.FormatUint(tokenId, 10), vault)

	std.Emit("NewVault", token0, token1, strconv.FormatUint(uint64(fee), 10), strconv.FormatUint(tokenId, 10))
}

// TogglePause pause deposits for a vault
// @param tokenId uint64 the vault id
func TogglePause(tokenId uint64) {
	accessControl.HasRole(std.PrevRealm().Addr(), "admin")

	vault := mustGetVault(tokenId)
	vault.paused = !vault.paused
}

// AddKeeper adds a keeper that can rebalance vaults
// @param keeper Address the address of the keeper
func AddKeeper(keeper std.Address) {
	accessControl.HasRole(std.PrevRealm().Addr(), "admin")

	accessControl.AddUserPerm(keeper, "role", "keeper")
}

/**
 * KEEPER FUNCTIONS
 */

// Rebalance rebalances the position of a vault
// @param tokenId uint64 the vault id
func Rebalance(tokenId uint64) {
	accessControl.HasRole(std.PrevRealm().Addr(), "keeper")

	vault := mustGetVault(tokenId)
	assertVaultPaused(vault)
}
