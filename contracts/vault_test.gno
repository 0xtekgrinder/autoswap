package autoswap

import (
	"std"
	"testing"

	"gno.land/p/demo/uint256"
	"gno.land/r/gnoswap/v2/bar"
	"gno.land/r/gnoswap/v2/consts"
	"gno.land/r/gnoswap/v2/foo"
)

func TestCreateVaultAsAdmin(t *testing.T) {
	initTokenRegistries()
	initPool()

	accessControl.AddUserPerm(adminRealm.Addr(), "role", "admin")

	std.TestSetRealm(adminRealm)
	bar.Approve(a2u(consts.POOL_ADDR), consts.UINT64_MAX)
	foo.Approve(a2u(consts.POOL_ADDR), consts.UINT64_MAX)

	tokenId, liquidity, amount0Used, amount1Used := NewVault(
		"gno.land/r/gnoswap/v2/bar",
		"gno.land/r/gnoswap/v2/foo",
		500,
		-887270,
		887270,
		"50000",
		"50000",
		"0",
		"0",
		999999999999,
	)

	shouldEQ(t, tokenId, uint64(1))
	shouldEQ(t, liquidity, "49997")   // average of both amounts
	shouldEQ(t, amount0Used, "49995") // 50000 - 5 for the fees
	shouldEQ(t, amount1Used, "50000")

	shouldEQ(t, GetVaultPaused(1), false)
	shouldEQ(t, GetVaultToken0(1), "gno.land/r/gnoswap/v2/bar")
	shouldEQ(t, GetVaultToken1(1), "gno.land/r/gnoswap/v2/foo")
	shouldEQ(t, GetVaultFee(1), uint32(500))
	shouldEQ(t, GetVaultWidth(1), uint32(887270*2))
}

func TestPauseVault(t *testing.T) {
	std.TestSetRealm(adminRealm)

	TogglePause(1)

	shouldEQ(t, GetVaultPaused(1), true)
}

func TestDepositMultiWhilePaused(t *testing.T) {
	std.TestSetRealm(adminRealm)

	shouldPanic(t, func() {
		DepositMulti(1, "50000", "50000", "0", "0", 999999999999)
	})
}

func TestUnPauseVault(t *testing.T) {
	std.TestSetRealm(adminRealm)

	TogglePause(1)

	shouldEQ(t, GetVaultPaused(1), false)
}

func TestDepositMulti(t *testing.T) {
	std.TestSetRealm(adminRealm)

	barBalanceBefore := bar.BalanceOf(a2u(adminRealm.Addr()))
	fooBalanceBefore := foo.BalanceOf(a2u(adminRealm.Addr()))

	liquidity, amount0Used, amount1Used := DepositMulti(1, "50000", "50000", "0", "0", 999999999999)

	shouldEQ(t, liquidity, "49997")
	shouldEQ(t, amount0Used, "49995")
	shouldEQ(t, amount1Used, "50000")

	shouldEQ(t, BalanceOf(1, fresh01.String()), "49997")

	barBalanceAfter := bar.BalanceOf(a2u(adminRealm.Addr()))
	fooBalanceAfter := foo.BalanceOf(a2u(adminRealm.Addr()))

	shouldEQ(t, barBalanceBefore-50000, barBalanceAfter)
	shouldEQ(t, fooBalanceBefore-49995, fooBalanceAfter)
}

func TestWithdrawHigherThanBalance(t *testing.T) {
	std.TestSetRealm(adminRealm)

	balance := BalanceOf(1, adminRealm.Addr().String())
	parsedBalance := uint256.MustFromDecimal(balance)

	shouldPanic(t, func() {
		Withdraw(1, parsedBalance.Add(parsedBalance, uint256.One()).ToString())
	})
}

func TestWithdrawWholeBalance(t *testing.T) {
	std.TestSetRealm(adminRealm)

	balance := BalanceOf(1, adminRealm.Addr().String())
	barBalanceBefore := bar.BalanceOf(a2u(adminRealm.Addr()))
	fooBalanceBefore := foo.BalanceOf(a2u(adminRealm.Addr()))

	liquidity, amount0, amount1 := Withdraw(1, balance)

	barBalanceAfter := bar.BalanceOf(a2u(adminRealm.Addr()))
	fooBalanceAfter := foo.BalanceOf(a2u(adminRealm.Addr()))
	newBalance := BalanceOf(1, adminRealm.Addr().String())

	shouldEQ(t, balance, liquidity)
	shouldEQ(t, newBalance, 0)
	shouldEQ(t, amount0, barBalanceAfter - barBalanceBefore)
	shouldEQ(t, amount1, fooBalanceAfter - fooBalanceBefore)
}

func TestRepositionNotAsKeeper(t *testing.T) {
	std.TestSetRealm(fresh02Realm)

	shouldPanic(t, func() {
		Reposition(1, 0, 1000, "50000", "50000", "0", "0")
	})
}

func TestCompoundNotAsKeeper(t *testing.T) {
	std.TestSetRealm(fresh02Realm)

	shouldPanic(t, func() {
		Compound(1)
	})
}

func TestAddKeeperNotAdmin(t *testing.T) {
	std.TestSetRealm(fresh02Realm)

	shouldPanic(t, func() {
		AddKeeper(fresh02)
	})
}

func TestAddKeeperAsAdmin(t *testing.T) {
	AddKeeper(fresh02)

	hasRole := accessControl.HasRole(fresh02, "keeper")
	shouldEQ(t, hasRole, true)
}

// func TestRemoveKeeperAsAdmin(t *testing.T) {
// 	RemoveKeeper(fresh02)
// }
//
// func TestRemoveKeeperNotAdmin(t *testing.T) {
// 	std.TestSetRealm(fresh02Realm)
//
// 	shouldPanic(t, func() {
// 		RemoveKeeper(fresh02)
// 	})
// }
