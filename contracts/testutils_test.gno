package autoswap

import (
	"std"
	"testing"

	pusers "gno.land/p/demo/users"

	"gno.land/r/gnoswap/v2/common"
	"gno.land/r/gnoswap/v2/consts"

	"gno.land/r/demo/wugnot"
	"gno.land/r/gnoswap/v2/gns"

	pl "gno.land/r/gnoswap/v2/pool"
)

func initPool() {
	std.TestSetRealm(adminRealm)
	pl.SetPoolCreationFeeByAdmin(0)
	pl.CreatePool(consts.GNOT, consts.GNS_PATH, 500, common.TickMathGetSqrtRatioAtTick(-10000).ToString())
}

type WugnotToken struct{}

func (WugnotToken) Transfer() func(to pusers.AddressOrName, amount uint64) {
	return wugnot.Transfer
}
func (WugnotToken) TransferFrom() func(from, to pusers.AddressOrName, amount uint64) {
	return wugnot.TransferFrom
}
func (WugnotToken) BalanceOf() func(owner pusers.AddressOrName) uint64 {
	return wugnot.BalanceOf
}
func (WugnotToken) Approve() func(spender pusers.AddressOrName, amount uint64) {
	return wugnot.Approve
}

type GNSToken struct{}

func (GNSToken) Transfer() func(to pusers.AddressOrName, amount uint64) {
	return gns.Transfer
}

func (GNSToken) TransferFrom() func(from, to pusers.AddressOrName, amount uint64) {
	return gns.TransferFrom
}

func (GNSToken) BalanceOf() func(owner pusers.AddressOrName) uint64 {
	return gns.BalanceOf
}

func (GNSToken) Approve() func(spender pusers.AddressOrName, amount uint64) {
	return gns.Approve
}

func initTokenRegistries() {
	RegisterGRC20Interface("gno.land/r/demo/wugnot", WugnotToken{})
	RegisterGRC20Interface("gno.land/r/gnoswap/v2/gns", GNSToken{})

	tokenRegisterRealm := std.NewUserRealm(consts.TOKEN_REGISTER)
	std.TestSetRealm(tokenRegisterRealm)

	pl.RegisterGRC20Interface("gno.land/r/demo/wugnot", WugnotToken{})
	pl.RegisterGRC20Interface("gno.land/r/gnoswap/v2/gns", GNSToken{})
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
