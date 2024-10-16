package gnoswap_optimizer

import (
	"std"
	"strconv"
	"time"

	"gno.land/p/demo/acl"
	"gno.land/p/demo/avl"
	"gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/v2/consts"
	"gno.land/r/gnoswap/v2/position"
)

var (
	vaults        *avl.Tree // tokenId -> *Vault
	accessControl *acl.Directory
)

func init() {
	vaults = avl.NewTree()
	accessControl = acl.New()

	accessControl.AddUserPerm(std.PrevRealm().Addr(), "role", "admin")
}

/**
 * USER FUNCTIONS
 */

// DepositMulti deposits tokens into a vault
// @param tokenId uint64 the vault id
// @param amount0 string the amount of token0 to deposit
// @param amount1 string the amount of token1 to deposit
// @param amount0Min string the minimum amount of token0 to deposit
// @param amount1Min string the minimum amount of token1 to deposit
// @param deadline int64 the deadline for the transaction
func DepositMulti(tokenId uint64, amount0 string, amount1 string, amount0Min string, amount1Min string, deadline int64) {
	vault := mustGetVault(tokenId)
	assertVaultPaused(vault)

	caller := std.PrevRealm().Addr()

	// Pull tokens from the caller
	transferFromByRegisterCall(vault.token0, caller, std.CurrentRealm().Addr(), amount0)
	transferFromByRegisterCall(vault.token1, caller, std.CurrentRealm().Addr(), amount1)

	// Approve the pool contract to spend the tokens
	poolAddr := consts.POOL_ADDR
	approveByRegisterCall(vault.token0, poolAddr, amount0)
	approveByRegisterCall(vault.token1, poolAddr, amount1)

	_, liquidity, amount0Used, amount1Used, _ := position.IncreaseLiquidity(tokenId, amount0, amount1, amount0Min, amount1Min, deadline)

	increaseBalance(vault, caller.String(), liquidity)

	// Send back any leftover tokens
	amount0Parsed := subAmounts(amount0, amount0Used)
	amount1Parsed := subAmounts(amount1, amount1Used)

	if amount0Parsed.Cmp(uint256.NewUint(0)) > 0 {
		transferByRegisterCall(vault.token0, caller, amount0Parsed.ToString())
	}
	if amount1Parsed.Cmp(uint256.NewUint(0)) > 0 {
		transferByRegisterCall(vault.token1, caller, amount1Parsed.ToString())
	}

	std.Emit("Deposit", caller.String(), strconv.FormatUint(tokenId, 10), amount0Parsed.ToString(), amount1Parsed.ToString(), liquidity)
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
	parsedAmount, err := uint256.FromDecimal(amount)
	if err != nil {
		panic(err)
	}
	if balance.Cmp(parsedAmount) < 0 {
		panic("insufficient balance")
	}

	liquidityRatio := computeLiquidityRatio(tokenId, parsedAmount)
	_, liquidity, _, _, amount0, amount1, _ := position.DecreaseLiquidity(tokenId, liquidityRatio, uint256.NewUint(0).ToString(), uint256.NewUint(0).ToString(), time.Now().Unix()+1, false)

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
// @param amount0 string the amount of token0 to deposit
// @param amount1 string the amount of token1 to deposit
// @param amount0Min string the minimum amount of token0 to deposit
// @param amount1Min string the minimum amount of token1 to deposit
// @param deadline int64 the deadline for the transaction
func NewVault(
	token0 string,
	token1 string,
	fee uint32,
	tickLower int32,
	tickUpper int32,
	amount0 string, // *uint256.Uint
	amount1 string, // *uint256.Uint
	amount0Min string, // *uint256.Uint
	amount1Min string, // *uint256.Uint
	deadline int64,
) {
	caller := std.PrevRealm().Addr()
	mustHaveRole(caller, "admin")

	tokenId, liquidity, amount0Used, amount1Used := position.Mint(token0, token1, fee, tickLower, tickUpper, amount0, amount1, amount0Min, amount1Min, deadline, std.CurrentRealm().Addr(), caller)

	// Create the vault and set the admin's balance
	vault := &Vault{
		balances: avl.NewTree(),
		paused:   false,
		token0:   token0,
		token1:   token1,
		fee:      fee,
		width:    uint32(tickUpper - tickLower),
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
	mustHaveRole(std.PrevRealm().Addr(), "admin")

	accessControl.AddUserPerm(keeper, "role", "keeper")
}

// RemoveKeeper removes a keeper
// @param keeper Address the address of the keeper
func RemoveKeeper(keeper std.Address) {
	mustHaveRole(std.PrevRealm().Addr(), "admin")

	// Awaiting the implementation of RemoveUserPerm in the ACL
	// accessControl.RemoveUserPerm(keeper, "role", "keeper")
}

/**
 * KEEPER FUNCTIONS
 */

// Reposition reposition a vault into a new tick range
// @param tokenId uint64 the vault id
// @param tickLower int32 the lower tick of the pool
// @param tickUpper int32 the upper tick of the pool
// @param amount0Desired string the amount of token0 to deposit
// @param amount1Desired string the amount of token1 to deposit
// @param amount0Min string the minimum amount of token0 to deposit
// @param amount1Min string the minimum amount of token1 to deposit
func Reposition(
	tokenId uint64,
	tickLower int32,
	tickUpper int32,
	amount0Desired string, // *uint256.Uint
	amount1Desired string, // *uint256.Uint
	amount0Min string, // *uint256.Uint
	amount1Min string, // *uint256.Uint
) {
	mustHaveRole(std.PrevRealm().Addr(), "keeper")

	vault := mustGetVault(tokenId)
	assertVaultPaused(vault)

	// Check width is correct
	if uint32(tickUpper-tickLower) != vault.width {
		panic("invalid tick range")
	}

	// TODO automaticly compute amount0 and amount1
	position.Reposition(tokenId, tickLower, tickUpper, amount0Desired, amount1Desired, amount0Min, amount1Min)

	std.Emit("Reposition", strconv.FormatUint(tokenId, 10), strconv.FormatInt(int64(tickLower), 10), strconv.FormatInt(int64(tickUpper), 10))
}
