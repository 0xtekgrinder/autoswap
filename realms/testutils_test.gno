package autoswap

import (
	"std"
	"testing"

	pusers "gno.land/p/demo/users"

	"gno.land/p/demo/testutils"
	"gno.land/r/gnoswap/v2/bar"
	"gno.land/r/gnoswap/v2/common"
	"gno.land/r/gnoswap/v2/consts"
	"gno.land/r/gnoswap/v2/foo"
	pl "gno.land/r/gnoswap/v2/pool"
)

var (
	fresh01      = testutils.TestAddress("fresh01") // g1veex2umgxqc47h6lta047h6lta047h6lgnrusf
	fresh02      = testutils.TestAddress("fresh02") // g1veex2umgxqe97h6lta047h6lta047h6lhqv0lu
	fresh01Realm = std.NewUserRealm(fresh01)
	fresh02Realm = std.NewUserRealm(fresh02)
	adminRealm   = std.NewUserRealm(consts.ADMIN)
)

func initPool() {
	std.TestSetRealm(adminRealm)

	bar.Transfer(a2u(fresh01), 10000000)
	foo.Transfer(a2u(fresh01), 10000000)

	pl.SetPoolCreationFeeByAdmin(0)
	pl.CreatePool("gno.land/r/gnoswap/v2/bar", "gno.land/r/gnoswap/v2/foo", 500, common.TickMathGetSqrtRatioAtTick(1).ToString())
}

type FooToken struct{}

func (FooToken) Transfer() func(to pusers.AddressOrName, amount uint64) {
	return foo.Transfer
}

func (FooToken) TransferFrom() func(from, to pusers.AddressOrName, amount uint64) {
	return foo.TransferFrom
}

func (FooToken) BalanceOf() func(owner pusers.AddressOrName) uint64 {
	return foo.BalanceOf
}

func (FooToken) Approve() func(spender pusers.AddressOrName, amount uint64) {
	return foo.Approve
}

type BarToken struct{}

func (BarToken) Transfer() func(to pusers.AddressOrName, amount uint64) {
	return bar.Transfer
}

func (BarToken) TransferFrom() func(from, to pusers.AddressOrName, amount uint64) {
	return bar.TransferFrom
}

func (BarToken) BalanceOf() func(owner pusers.AddressOrName) uint64 {
	return bar.BalanceOf
}

func (BarToken) Approve() func(spender pusers.AddressOrName, amount uint64) {
	return bar.Approve
}

func initTokenRegistries() {
	RegisterGRC20Interface("gno.land/r/gnoswap/v2/foo", FooToken{})
	RegisterGRC20Interface("gno.land/r/gnoswap/v2/bar", BarToken{})

	tokenRegisterRealm := std.NewUserRealm(consts.TOKEN_REGISTER)
	std.TestSetRealm(tokenRegisterRealm)

	pl.RegisterGRC20Interface("gno.land/r/gnoswap/v2/foo", FooToken{})
	pl.RegisterGRC20Interface("gno.land/r/gnoswap/v2/bar", BarToken{})
}

func a2u(addr std.Address) pusers.AddressOrName {
	return pusers.AddressOrName(addr)
}

func shouldEQ(t *testing.T, got, expected interface{}) {
	if got != expected {
		t.Errorf("got %v, expected %v", got, expected)
	}
}

func shouldNEQ(t *testing.T, got, expected interface{}) {
	if got == expected {
		t.Errorf("got %v, didn't expected %v", got, expected)
	}
}

func shouldPanic(t *testing.T, f func()) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("expected panic")
		}
	}()
	f()
}

func shouldPanicWithMsg(t *testing.T, f func(), msg string) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("The code did not panic")
		} else {
			if r != msg {
				t.Errorf("excepted panic(%v), got(%v)", msg, r)
			}
		}
	}()
	f()
}
