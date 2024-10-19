package gnoswap_optimizer

import (
	"std"
	
	"gno.land/p/demo/ufmt"
	pusers "gno.land/p/demo/users"
	"gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/v2/consts"
	"gno.land/p/demo/avl"
)

type GRC20Interface interface {
	Transfer() func(to pusers.AddressOrName, amount uint64)
	TransferFrom() func(from, to pusers.AddressOrName, amount uint64)
	BalanceOf() func(owner pusers.AddressOrName) uint64
	Approve() func(spender pusers.AddressOrName, amount uint64)
}

var (
	registered  *avl.Tree // pkgPath -> GRC20Interface
	locked      bool 	// prevent reentrancy
)

func init() {
	registered = avl.NewTree()
}

func RegisterGRC20Interface(pkgPath string, igrc20 GRC20Interface) {
	caller := std.PrevRealm().Addr()
	mustHaveRole(caller, "admin")

	pkgPath = handleNative(pkgPath)

	_, found := registered.Get(pkgPath)
	if found {
		panic(ufmt.Sprintf("pkgPath(%s) already registered", pkgPath))
	}

	registered.Set(pkgPath, igrc20)
}

func UnregisterGRC20Interface(pkgPath string) {
	caller := std.PrevRealm().Addr()
	mustHaveRole(caller, "admin")

	pkgPath = handleNative(pkgPath)

	_, found := registered.Get(pkgPath)
	if !found {
		panic(ufmt.Sprintf("pkgPath(%s) not registered", pkgPath))
	}
	registered.Remove(pkgPath)
}

func transferByRegisterCall(pkgPath string, to std.Address, amount string) bool {
	amountParsed := checkAmountRange(amount)
	pkgPath = handleNative(pkgPath)

	grc20 := mustGetRegistered(pkgPath)

	if !locked {
		locked = true
		grc20.Transfer()(pusers.AddressOrName(to), amountParsed)

		defer func() {
			locked = false
		}()
	} else {
		panic("expected locked to be false")
	}
	return true
}

func transferFromByRegisterCall(pkgPath string, from, to std.Address, amount string) bool {
	amountParsed := checkAmountRange(amount)
	pkgPath = handleNative(pkgPath)

	grc20 := mustGetRegistered(pkgPath)

	if !locked {
		locked = true
		grc20.TransferFrom()(pusers.AddressOrName(from), pusers.AddressOrName(to), amountParsed)

		defer func() {
			locked = false
		}()
	} else {
		panic("expected locked to be false")
	}
	return true
}

func balanceOfByRegisterCall(pkgPath string, owner std.Address) uint64 {
	pkgPath = handleNative(pkgPath)

	grc20 := mustGetRegistered(pkgPath)

	balance := grc20.BalanceOf()(pusers.AddressOrName(owner))
	return balance
}

func approveByRegisterCall(pkgPath string, spender std.Address, amount string) bool {
	amountParsed := checkAmountRange(amount)
	pkgPath = handleNative(pkgPath)

	grc20 := mustGetRegistered(pkgPath)

	grc20.Approve()(pusers.AddressOrName(spender), amountParsed)

	return true
}

func handleNative(pkgPath string) string {
	if pkgPath == consts.GNOT {
		return consts.WRAPPED_WUGNOT
	}

	return pkgPath
}

func checkAmountRange(amount string) uint64 {
	// check amount is in uint64 range
	amountParsed, err := uint256.FromDecimal(amount)
	if err != nil {
		panic(ufmt.Sprintf("amount(%s) is not in uint64 range", amount))
	}

	return amountParsed.Uint64()
}
