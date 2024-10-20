package autoswap

import (
	"std"
	"testing"

	"gno.land/r/gnoswap/v2/consts"
	"gno.land/r/demo/wugnot"
	"gno.land/r/gnoswap/v2/gns"
)

func TestCreateVaultAsAdmin(t *testing.T) {
	initTokenRegistries()
	initPool()

	gns.Approve(a2u(consts.POOL_ADDR), consts.UINT64_MAX)    // POOL FOR MINT
	wugnot.Approve(a2u(consts.POOL_ADDR), consts.UINT64_MAX) // POOL FOR MINT

	// NewVault(
	// 	consts.GNS_PATH, // token0
	// 	consts.GNOT,     // token1
	// 	500,          // fee
	// 	12000,           // tickLower
	// 	14000,           // tickUpper
	// 	"10000000",      // amount0Desired
	// 	"10000000",      // amount1Desired
	// 	"0",             // amount0Min
	// 	"0",             // amount1Min
	// 	9999999999999999,     // deadline
	// )
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
