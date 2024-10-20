package autoswap

import (
	"std"
	"testing"

	"gno.land/r/gnoswap/v2/consts"
)

func TestRegisterGRC20InterfaceNotAsAdmin(t *testing.T) {
	std.TestSetRealm(std.NewUserRealm(consts.ADMIN))

	shouldPanic(t, func() {
		RegisterGRC20Interface("pkgPath", GNSToken{})
	})
}

func TestRegisterGRC20Interface(t *testing.T) {
	RegisterGRC20Interface("pkgPath", GNSToken{})

	grc20, found := registered.Get("pkgPath")

	shouldEQ(t, found, true)
	shouldEQ(t, grc20, GNSToken{})
}

func TestRegisterGRC20InterfaceAlreadyRegistered(t *testing.T) {
	shouldPanic(t, func() {
		RegisterGRC20Interface("pkgPath", GNSToken{})
	})
}

func TestUnregisterGRC20InterfaceNotAsAdmin(t *testing.T) {
	std.TestSetRealm(std.NewUserRealm(consts.ADMIN))

	shouldPanic(t, func() {
		UnregisterGRC20Interface("pkgPath")
	})
}

func TestUnregisterGRC20Interface(t *testing.T) {
	UnregisterGRC20Interface("pkgPath")

	_, found := registered.Get("pkgPath")

	shouldEQ(t, found, false)
}

func TestUnregisterGRC20InterfaceNotRegistered(t *testing.T) {
	shouldPanic(t, func() {
		UnregisterGRC20Interface("pkgPath")
	})
}
