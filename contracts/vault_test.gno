package autoswap

import (
	"std"
	"testing"

	"gno.land/p/demo/testutils"

	"gno.land/r/gnoswap/v2/consts"

	"gno.land/r/demo/wugnot"
	"gno.land/r/gnoswap/v2/gns"
)

// fresh users
var (
	fresh01    = testutils.TestAddress("fresh01") // g1veex2umgxqc47h6lta047h6lta047h6lgnrusf
	fresh02    = testutils.TestAddress("fresh02") // g1veex2umgxqe97h6lta047h6lta047h6lhqv0lu
	adminRealm = std.NewUserRealm(consts.ADMIN)
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
	std.TestSetRealm(adminRealm)

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
// 	std.TestSetRealm(adminRealm)
//
// 	shouldPanic(t, func() {
// 		RemoveKeeper(fresh02)
// 	})
// }
