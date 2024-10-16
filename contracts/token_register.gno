package gnoswap_optimizer

import (
	"fmt"
	"std"

	pusers "gno.land/p/demo/users"
	"gno.land/p/gnoswap/uint256"
	"gno.land/r/gnoswap/v2/consts"
)

type GRC20Interface interface {
	Transfer() func(to pusers.AddressOrName, amount uint64)
	TransferFrom() func(from, to pusers.AddressOrName, amount uint64)
	BalanceOf() func(owner pusers.AddressOrName) uint64
	Approve() func(spender pusers.AddressOrName, amount uint64)
}

var (
	registered = make(map[string]GRC20Interface)
	locked     = false // mutex
)

func GetRegisteredTokens() []string {
	tokens := make([]string, 0, len(registered))
	for k := range registered {
		tokens = append(tokens, k)
	}

	return tokens
}

func RegisterGRC20Interface(pkgPath string, igrc20 GRC20Interface) {
	caller := std.PrevRealm().Addr()
	if caller != consts.TOKEN_REGISTER {
		panic(fmt.Sprintf("unauthorized address(%s) to register", caller.String()))
	}

	pkgPath = handleNative(pkgPath)

	_, found := registered[pkgPath]
	if found {
		panic(fmt.Sprintf("pkgPath(%s) already registered", pkgPath))
	}

	registered[pkgPath] = igrc20
}

func UnregisterGRC20Interface(pkgPath string) {
	// only admin can unregister
	caller := std.PrevRealm().Addr()
	if caller != consts.TOKEN_REGISTER {
		panic(fmt.Sprintf("unauthorized address(%s) to unregister", caller.String()))
	}

	pkgPath = handleNative(pkgPath)

	_, found := registered[pkgPath]
	if found {
		delete(registered, pkgPath)
	}
}

func transferByRegisterCall(pkgPath string, to std.Address, amount string) bool {
	amountParsed := checkAmountRange(amount)
	pkgPath = handleNative(pkgPath)

	_, found := registered[pkgPath]
	if !found {
		panic(fmt.Sprintf("pkgPath(%s) not found", pkgPath))
	}

	if !locked {
		locked = true
		registered[pkgPath].Transfer()(pusers.AddressOrName(to), amountParsed)

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

	_, found := registered[pkgPath]
	if !found {
		panic(fmt.Sprintf("pkgPath(%s) not found", pkgPath))
	}

	if !locked {
		locked = true
		registered[pkgPath].TransferFrom()(pusers.AddressOrName(from), pusers.AddressOrName(to), amountParsed)

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

	_, found := registered[pkgPath]
	if !found {
		panic(fmt.Sprintf("pkgPath(%s) not found", pkgPath))
	}

	balance := registered[pkgPath].BalanceOf()(pusers.AddressOrName(owner))
	return balance
}

func approveByRegisterCall(pkgPath string, spender std.Address, amount string) bool {
	amountParsed := checkAmountRange(amount)
	pkgPath = handleNative(pkgPath)

	_, found := registered[pkgPath]
	if !found {
		panic(fmt.Sprintf("pkgPath(%s) not found", pkgPath))
	}

	registered[pkgPath].Approve()(pusers.AddressOrName(spender), amountParsed)

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
		panic(fmt.Sprintf("amount(%s) is not in uint64 range", amount))
	}

	return amountParsed.Uint64()
}
